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

  /** True if this request is allowed. */
  take(ip: string): boolean {
    const now = this.now();
    const window = this.windows.get(ip);
    if (!window || now - window.start >= 60_000) {
      this.windows.set(ip, { start: now, count: 1 });
      if (this.windows.size > 10_000) this.prune(now);
      return true;
    }
    if (window.count >= this.perMinute) return false;
    window.count++;
    return true;
  }

  private prune(now: number) {
    for (const [ip, w] of this.windows) if (now - w.start >= 60_000) this.windows.delete(ip);
  }
}

/** Token counts for one request, summed over every attempt (fallbacks included). */
export interface TokenUsage {
  input: number;
  output: number;
  cacheWrite: number;
  cacheRead: number;
}

/**
 * Estimated dollars at Claude Opus 5.5's list prices ($4 / $20 per million
 * tokens, cache writes 1.25x input, cache reads $0.20). A fallback model may
 * cost less, so this errs high, which is the safe side for a cap.
 */
export function costUsd(usage: TokenUsage): number {
  return (usage.input * 4 + usage.cacheWrite * 5 + usage.cacheRead * 0.2 + usage.output * 20) / 1_000_000;
}

/** Spend since midnight UTC, per instance. */
export class SpendMeter {
  private day = "";
  private spentUsd = 0;

  constructor(
    private readonly capUsd: number,
    private readonly now: () => number = Date.now,
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
    this.spentUsd += costUsd(usage);
  }

  get spent(): number {
    this.rollover();
    return this.spentUsd;
  }
}
