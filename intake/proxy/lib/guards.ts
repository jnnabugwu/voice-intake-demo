/**
 * Best-effort guards, per serverless instance: a CORS allowlist, a per-IP rate
 * limit and a daily spend cap. The hard ceiling is the spend limit on the
 * Claude Console workspace.
 */

export interface GuardConfig {
  allowedOrigins: string[];
  ratePerMinute: number;
  dailyCapUsd: number;
}

export function guardConfig(env: NodeJS.ProcessEnv = process.env): GuardConfig {
  return {
    allowedOrigins: (env.ALLOWED_ORIGINS ?? "")
      .split(",")
      .map((o) => o.trim().replace(/\/$/, ""))
      .filter(Boolean),
    ratePerMinute: positive(env.RATE_LIMIT_PER_MIN, 20),
    dailyCapUsd: nonNegative(env.DAILY_SPEND_CAP_USD, 5),
  };
}

function positive(raw: string | undefined, fallback: number): number {
  const n = Number(raw);
  return raw !== undefined && Number.isFinite(n) && n > 0 ? n : fallback;
}

function nonNegative(raw: string | undefined, fallback: number): number {
  const n = Number(raw);
  return raw !== undefined && raw !== "" && Number.isFinite(n) && n >= 0 ? n : fallback;
}

const LOCALHOST = /^http:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/;

export function isAllowedOrigin(origin: string | null, config: GuardConfig): boolean {
  if (!origin) return false;
  return LOCALHOST.test(origin) || config.allowedOrigins.includes(origin);
}

/** CORS headers for an allowed origin, or none. */
export function corsHeaders(origin: string | null, config: GuardConfig): Record<string, string> {
  if (!origin || !isAllowedOrigin(origin, config)) return {};
  return {
    "access-control-allow-origin": origin,
    "access-control-allow-methods": "POST, OPTIONS",
    "access-control-allow-headers": "content-type",
    "access-control-max-age": "600",
    vary: "origin",
  };
}

export function clientIp(request: Request): string {
  const forwarded = request.headers.get("x-forwarded-for");
  return forwarded?.split(",")[0]?.trim() || request.headers.get("x-real-ip") || "unknown";
}

/** Fixed one-minute windows per IP. */
export class RateLimiter {
  private readonly windows = new Map<string, { start: number; count: number }>();

  constructor(
    private readonly perMinute: number,
    private readonly now: () => number = Date.now,
  ) {}

  static readonly maxTracked = 10_000;

  /** True if this request is allowed. */
  take(ip: string): boolean {
    const now = this.now();
    const window = this.windows.get(ip);
    if (!window || now - window.start >= 60_000) {
      // Re-insert so the map stays ordered oldest window first.
      this.windows.delete(ip);
      this.windows.set(ip, { start: now, count: 1 });
      this.evictOldest(now);
      return true;
    }
    if (window.count >= this.perMinute) return false;
    window.count++;
    return true;
  }

  /** Drops expired windows from the front, then the oldest beyond the bound. O(evicted). */
  private evictOldest(now: number) {
    for (const [ip, w] of this.windows) {
      if (this.windows.size <= RateLimiter.maxTracked && now - w.start < 60_000) break;
      this.windows.delete(ip);
    }
  }

  get tracked(): number {
    return this.windows.size;
  }
}

/** Token counts for one request, summed over every attempt (fallbacks included). */
export interface TokenUsage {
  input: number;
  output: number;
  cacheWrite: number;
  cacheRead: number;
}

/** List prices, dollars per million input / output tokens. */
const PRICES: Record<string, { input: number; output: number }> = {
  "claude-opus-5-5": { input: 4, output: 20 },
  "claude-opus-5": { input: 5, output: 25 },
  "claude-opus-4-8": { input: 5, output: 25 },
  "claude-sonnet-5-5": { input: 2, output: 10 },
  "claude-haiku-5-5": { input: 0.1, output: 0.5 },
};

/** A model not in the table is priced as the most expensive one, so the cap errs safe. */
const UNKNOWN = { input: 10, output: 50 };

/**
 * Estimated dollars for [model] (cache writes 1.25x input, reads 0.1x). Fallback
 * attempts are priced as the primary model; the refusal fallbacks are the same
 * price or cheaper, so this errs high, the safe side for a cap.
 */
export function costUsd(usage: TokenUsage, model = "claude-opus-5-5"): number {
  const p = PRICES[model] ?? UNKNOWN;
  return (
    (usage.input * p.input + usage.cacheWrite * p.input * 1.25 + usage.cacheRead * p.input * 0.1 + usage.output * p.output) /
    1_000_000
  );
}

/** Spend since midnight UTC, per instance. */
export class SpendMeter {
  private day = "";
  private spentUsd = 0;

  constructor(
    private readonly capUsd: number,
    private readonly now: () => number = Date.now,
    private readonly model: () => string = () => process.env.CLAUDE_MODEL || "claude-opus-5-5",
  ) {}

  private rollover() {
    const today = new Date(this.now()).toISOString().slice(0, 10);
    if (today !== this.day) {
      this.day = today;
      this.spentUsd = 0;
    }
  }

  isOverCap(): boolean {
    this.rollover();
    return this.spentUsd >= this.capUsd;
  }

  record(usage: TokenUsage): void {
    this.rollover();
    this.spentUsd += costUsd(usage, this.model());
  }

  get spent(): number {
    this.rollover();
    return this.spentUsd;
  }
}
