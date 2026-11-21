import { describe, expect, it } from "vitest";
import { corsHeaders, costUsd, guardConfig, isAllowedOrigin, RateLimiter, SpendMeter } from "../lib/guards.js";

const config = guardConfig({ ALLOWED_ORIGINS: "https://intake.example.app/, https://other.example" });

describe("CORS allowlist", () => {
  it("allows the deployed origins and localhost on any port", () => {
    expect(isAllowedOrigin("https://intake.example.app", config)).toBe(true);
    expect(isAllowedOrigin("http://localhost:54321", config)).toBe(true);
    expect(isAllowedOrigin("http://127.0.0.1:8080", config)).toBe(true);
  });

  it("rejects everything else", () => {
    expect(isAllowedOrigin("https://evil.example", config)).toBe(false);
    expect(isAllowedOrigin("http://localhost.evil.example", config)).toBe(false);
    expect(isAllowedOrigin(null, config)).toBe(false);
    expect(corsHeaders("https://evil.example", config)).toEqual({});
  });

  it("echoes an allowed origin", () => {
    expect(corsHeaders("http://localhost:3000", config)["access-control-allow-origin"]).toBe("http://localhost:3000");
  });
});

describe("config", () => {
  it("defaults and accepts a zero cap", () => {
    expect(guardConfig({})).toMatchObject({ ratePerMinute: 20, dailyCapUsd: 5 });
    expect(guardConfig({ DAILY_SPEND_CAP_USD: "0" }).dailyCapUsd).toBe(0);
    expect(guardConfig({ RATE_LIMIT_PER_MIN: "nope" }).ratePerMinute).toBe(20);
  });
});

describe("RateLimiter", () => {
  it("stays bounded under a flood of distinct IPs", () => {
    const limiter = new RateLimiter(5, () => 0);
    for (let i = 0; i < RateLimiter.maxTracked + 500; i++) limiter.take(`10.0.${i}`);
    expect(limiter.tracked).toBeLessThanOrEqual(RateLimiter.maxTracked);
  });

  it("allows N per minute per IP, then resets", () => {
    let t = 0;
    const limiter = new RateLimiter(2, () => t);
    expect([limiter.take("a"), limiter.take("a"), limiter.take("a")]).toEqual([true, true, false]);
    expect(limiter.take("b")).toBe(true);
    t = 60_000;
    expect(limiter.take("a")).toBe(true);
  });
});

describe("SpendMeter", () => {
  it("prices at Opus 5.5 rates and resets at midnight UTC", () => {
    expect(costUsd({ input: 1_000_000, output: 1_000_000, cacheWrite: 0, cacheRead: 0 })).toBeCloseTo(24);
    let t = Date.parse("2026-11-20T23:59:00Z");
    const meter = new SpendMeter(0.01, () => t);
    expect(meter.isOverCap()).toBe(false);
    meter.record({ input: 0, output: 1000, cacheWrite: 0, cacheRead: 0 }); // $0.02
    expect(meter.isOverCap()).toBe(true);
    t = Date.parse("2026-11-21T00:00:01Z");
    expect(meter.isOverCap()).toBe(false);
  });

  it("prices the configured model, and an unknown one at the top rate", () => {
    const u = { input: 1_000_000, output: 1_000_000, cacheWrite: 0, cacheRead: 0 };
    expect(costUsd(u, "claude-opus-5")).toBeCloseTo(30);
    expect(costUsd(u, "claude-someday-9")).toBeCloseTo(60);
  });

  it("a zero cap blocks everything", () => {
    expect(new SpendMeter(0).isOverCap()).toBe(true);
  });
});
