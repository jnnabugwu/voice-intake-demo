import Anthropic from "@anthropic-ai/sdk";
import { betaZodOutputFormat } from "@anthropic-ai/sdk/helpers/beta/zod";
import type { TokenUsage } from "./guards.js";
import { ModelSummary } from "../contract/summary.js";
import type { z } from "zod";

export const model = () => process.env.CLAUDE_MODEL || "claude-opus-5-5";

/**
 * Server-side refusal fallback: a declined request is re-run inside the same
 * call on the model Anthropic recommends for that refusal category.
 */
const FALLBACK = {
  betas: ["server-side-fallback-2026-07-01"] as Anthropic.Beta.AnthropicBeta[],
  fallbacks: "default" as const,
};

let client: Anthropic | undefined;
export const anthropic = () => (client ??= new Anthropic());

export type ChatMessage = { role: "user" | "assistant"; text: string };

export type ReplyEvent =
  | { type: "text"; text: string }
  | { type: "end"; refused: boolean; usage: TokenUsage };

export type ReplyStream = (input: {
  system: string;
  messages: ChatMessage[];
  /** Running totals as the stream goes, so a reply cut short is still metered. */
  onUsage?: (usage: TokenUsage) => void;
  /** Aborts the upstream request, e.g. when the client disconnects. */
  signal?: AbortSignal;
}) => AsyncIterable<ReplyEvent>;

/**
 * Streams one chat reply. Effort is `low`: a turn is a short acknowledgment and
 * one question, and latency matters more than depth.
 */
export const streamReply: ReplyStream = async function* ({ system, messages, onUsage, signal }) {
  const stream = anthropic().beta.messages.stream(
    {
      model: model(),
      max_tokens: 4096,
      ...FALLBACK,
      output_config: { effort: "low" },
      system,
      messages: toApiMessages(messages),
    },
    { signal },
  );
  let input = 0;
  for await (const event of stream) {
    if (event.type === "message_start") {
      input = event.message.usage.input_tokens;
      onUsage?.({ input, output: event.message.usage.output_tokens, cacheWrite: 0, cacheRead: 0 });
    } else if (event.type === "message_delta") {
      onUsage?.({ input, output: event.usage.output_tokens, cacheWrite: 0, cacheRead: 0 });
    } else if (event.type === "content_block_delta" && event.delta.type === "text_delta") {
      yield { type: "text", text: event.delta.text };
    }
  }
  const final = await stream.finalMessage();
  yield { type: "end", refused: final.stop_reason === "refusal", usage: totalUsage(final.usage) };
};

export type SummaryResult =
  | { type: "ok"; summary: z.infer<typeof ModelSummary>; usage: TokenUsage }
  | { type: "refused"; usage: TokenUsage };

export type Summarize = (input: { system: string; transcript: string }) => Promise<SummaryResult>;

/** Structured summary at the model's default effort. */
export const summarize: Summarize = async ({ system, transcript }) => {
  // create, not parse: the response (and what it cost) comes back even when the
  // output fails validation, so the spend cap counts every billed summary.
  const response = await anthropic().beta.messages.create({
    model: model(),
    max_tokens: 16000,
    ...FALLBACK,
    system,
    messages: [{ role: "user", content: `Conversation transcript:\n\n${transcript}` }],
    output_config: { format: betaZodOutputFormat(ModelSummary) },
  });
  const usage = totalUsage(response.usage);
  if (response.stop_reason === "refusal") return { type: "refused", usage };
  const parsed = parseSummary(response.content);
  return parsed ? { type: "ok", summary: parsed, usage } : { type: "refused", usage };
};

/** The structured output, validated against the schema (including severity 1-10), or null. */
export function parseSummary(content: ReadonlyArray<{ type: string; text?: string }>): z.infer<typeof ModelSummary> | null {
  const text = content.find((b) => b.type === "text")?.text;
  if (!text) return null;
  try {
    const result = ModelSummary.safeParse(JSON.parse(text));
    return result.success ? result.data : null;
  } catch {
    return null;
  }
}

/**
 * The Messages API wants alternating roles starting with the user. A failed
 * reply followed by a new message leaves two worker turns in a row, so
 * neighbours with the same role are joined.
 */
export function toApiMessages(messages: ChatMessage[]): Anthropic.Beta.BetaMessageParam[] {
  const merged: ChatMessage[] = [];
  for (const m of messages) {
    const last = merged.at(-1);
    if (last && last.role === m.role) last.text = `${last.text}\n${m.text}`;
    else merged.push({ ...m });
  }
  while (merged[0]?.role === "assistant") merged.shift();
  return merged.map((m) => ({ role: m.role, content: m.text }));
}

type UsageLike = {
  input_tokens: number;
  output_tokens: number;
  cache_creation_input_tokens?: number | null;
  cache_read_input_tokens?: number | null;
  iterations?: ReadonlyArray<{
    input_tokens?: number | null;
    output_tokens?: number | null;
    cache_creation_input_tokens?: number | null;
    cache_read_input_tokens?: number | null;
  }> | null;
};

/** Sums every attempt: a refused attempt plus its fallback both cost tokens. */
export function totalUsage(usage: UsageLike): TokenUsage {
  const parts = usage.iterations?.length ? usage.iterations : [usage];
  return parts.reduce<TokenUsage>(
    (sum, p) => ({
      input: sum.input + (p.input_tokens ?? 0),
      output: sum.output + (p.output_tokens ?? 0),
      cacheWrite: sum.cacheWrite + (p.cache_creation_input_tokens ?? 0),
      cacheRead: sum.cacheRead + (p.cache_read_input_tokens ?? 0),
    }),
    { input: 0, output: 0, cacheWrite: 0, cacheRead: 0 },
  );
}
