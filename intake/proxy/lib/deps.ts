import { streamReply, summarize } from "./claude.js";
import { guardConfig, RateLimiter, SpendMeter } from "./guards.js";
import type { Deps } from "./handlers.js";

const config = guardConfig();

/** One set per serverless instance; both routes share the spend meter. */
export const deps: Deps = {
  config,
  limiter: new RateLimiter(config.ratePerMinute),
  meter: new SpendMeter(config.dailyCapUsd),
  reply: streamReply,
  summarize,
};
