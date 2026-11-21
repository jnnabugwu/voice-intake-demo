import { chatSystemPrompt } from "../prompts/chat.js";
import { summarySystemPrompt } from "../prompts/summary.js";
import type { IntakeSummary } from "../contract/summary.js";
import type { ReplyStream, Summarize } from "./claude.js";
import { clientIp, corsHeaders, isAllowedOrigin, RateLimiter, SpendMeter, type GuardConfig } from "./guards.js";
import { ChatRequest, json, logRequest, SummaryRequest } from "./http.js";
import { detectRedFlag } from "./red_flags.js";
import type { TokenUsage } from "./guards.js";
import { sseEvent, sseHeaders } from "./sse.js";

export interface Deps {
  config: GuardConfig;
  limiter: RateLimiter;
  meter: SpendMeter;
  reply: ReplyStream;
  summarize: Summarize;
  now?: () => number;
}

/** Turns already answered, by conversation and turn ID, so a retry replays instead of paying twice. */
class AnsweredTurns {
  private readonly replies = new Map<string, string>();
  get(key: string) {
    return this.replies.get(key);
  }
  set(key: string, text: string) {
    this.replies.set(key, text);
    if (this.replies.size > 500) this.replies.delete(this.replies.keys().next().value!);
  }
}

type Gate = { ok: true; cors: Record<string, string> } | { ok: false; response: Response };

/**
 * The origin check, and the per-IP rate limit unless [rateLimit] is false.
 * Chat skips it here and applies it after the red-flag check, so an
 * emergency is never answered with a 429.
 */
function gate(request: Request, deps: Deps, { rateLimit = true } = {}): Gate {
  const origin = request.headers.get("origin");
  const cors = corsHeaders(origin, deps.config);
  // No Origin means a non-browser client (curl); CORS doesn't apply to it.
  if (origin && !isAllowedOrigin(origin, deps.config)) {
    return { ok: false, response: json(403, { code: "forbidden_origin" }) };
  }
  if (rateLimit && !deps.limiter.take(clientIp(request))) {
    return { ok: false, response: json(429, { code: "rate_limited" }, cors) };
  }
  return { ok: true, cors };
}

function overCap(deps: Deps, cors: Record<string, string>, route: string): Response | null {
  if (!deps.meter.isOverCap()) return null;
  logRequest({ route, status: 429, code: "spend_cap" });
  return json(429, { code: "spend_cap" }, cors);
}

async function readJson(request: Request): Promise<unknown> {
  try {
    return await request.json();
  } catch {
    return undefined;
  }
}

export function createChatHandler(deps: Deps) {
  const answered = new AnsweredTurns();
  const now = deps.now ?? Date.now;

  return async function POST(request: Request): Promise<Response> {
    const started = now();
    const g = gate(request, deps, { rateLimit: false });
    if (!g.ok) {
      logRequest({ route: "chat", status: g.response.status });
      return g.response;
    }
    const parsed = ChatRequest.safeParse(await readJson(request));
    if (!parsed.success) return json(400, { code: "bad_request" }, g.cors);
    const body = parsed.data;
    // The whole request, serialized: a reused turn ID with different messages
    // is a different request, and IDs containing a delimiter can't collide.
    const key = JSON.stringify([body.conversationId, body.turnId, body.language, body.messages]);
    const headers = { ...sseHeaders, ...g.cors };

    // Red flags stop the chat before any model call, a replay, the rate limit or
    // the spend cap: this path costs nothing, so an emergency never gets a 429.
    const flag = detectRedFlag(body.messages.at(-1)!.text);
    if (flag) {
      logRequest({ route: "chat", status: 200, redFlag: flag });
      return new Response(sseEvent("red_flag", { kind: flag }), { headers });
    }
    if (!deps.limiter.take(clientIp(request))) {
      logRequest({ route: "chat", status: 429, code: "rate_limited" });
      return json(429, { code: "rate_limited" }, g.cors);
    }

    const cached = answered.get(key);
    if (cached !== undefined) {
      logRequest({ route: "chat", status: 200, replayed: true });
      return new Response(sseEvent("delta", { text: cached }) + sseEvent("done"), { headers });
    }
    const capped = overCap(deps, g.cors, "chat");
    if (capped) return capped;

    const encoder = new TextEncoder();
    const upstream = new AbortController();
    const stream = new ReadableStream<Uint8Array>({
      async start(controller) {
        const send = (chunk: string) => {
          if (!upstream.signal.aborted) controller.enqueue(encoder.encode(chunk));
        };
        let text = "";
        let firstTokenMs: number | undefined;
        let partial: TokenUsage | undefined;
        let metered = false;
        try {
          for await (const event of deps.reply({
            system: chatSystemPrompt(body.language),
            messages: body.messages,
            onUsage: (u) => (partial = u),
            signal: upstream.signal,
          })) {
            if (event.type === "text") {
              firstTokenMs ??= now() - started;
              text += event.text;
              send(sseEvent("delta", { text: event.text }));
            } else {
              deps.meter.record(event.usage);
              metered = true;
              if (event.refused) {
                send(sseEvent("refusal"));
              } else {
                answered.set(key, text);
                send(sseEvent("done"));
              }
              logRequest({
                route: "chat",
                status: 200,
                refused: event.refused,
                firstTokenMs: firstTokenMs ?? -1,
                totalMs: now() - started,
                inputTokens: event.usage.input,
                outputTokens: event.usage.output,
              });
            }
          }
        } catch (error) {
          send(sseEvent("error", { code: "upstream" }));
          logRequest({ route: "chat", status: 502, error: error instanceof Error ? error.name : "unknown" });
        } finally {
          // A reply cut short (error or disconnect) still spent what it generated.
          if (!metered && partial) deps.meter.record(partial);
          if (!upstream.signal.aborted) controller.close();
        }
      },
      cancel() {
        upstream.abort();
      },
    });
    return new Response(stream, { headers });
  };
}

export function createSummaryHandler(deps: Deps) {
  const now = deps.now ?? Date.now;

  return async function POST(request: Request): Promise<Response> {
    const started = now();
    const g = gate(request, deps);
    if (!g.ok) {
      logRequest({ route: "summary", status: g.response.status });
      return g.response;
    }
    const parsed = SummaryRequest.safeParse(await readJson(request));
    if (!parsed.success) return json(400, { code: "bad_request" }, g.cors);
    const body = parsed.data;
    const capped = overCap(deps, g.cors, "summary");
    if (capped) return capped;

    try {
      const result = await deps.summarize({ system: summarySystemPrompt, transcript: body.transcript });
      deps.meter.record(result.usage);
      const log = { route: "summary", totalMs: now() - started, inputTokens: result.usage.input, outputTokens: result.usage.output };
      if (result.type === "refused") {
        logRequest({ ...log, status: 502, refused: true });
        return json(502, { code: "upstream" }, g.cors);
      }
      logRequest({ ...log, status: 200 });
      const summary: IntakeSummary = { ...result.summary, language: body.language, transcript: body.transcript };
      return json(200, summary, g.cors);
    } catch (error) {
      logRequest({ route: "summary", status: 502, error: error instanceof Error ? error.name : "unknown" });
      return json(502, { code: "upstream" }, g.cors);
    }
  };
}
