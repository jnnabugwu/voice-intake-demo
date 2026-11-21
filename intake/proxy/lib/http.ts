import { z } from "zod";
import { corsHeaders, type GuardConfig } from "./guards.js";

export const Language = z.enum(["en", "es"]);

export const ChatRequest = z.object({
  conversationId: z.string().min(1).max(100),
  turnId: z.string().min(1).max(100),
  language: Language,
  messages: z
    .array(z.object({ role: z.enum(["user", "assistant"]), text: z.string().min(1).max(4000) }))
    .min(1)
    .max(60)
    .refine((m) => m.at(-1)?.role === "user", "the last message must be the worker's"),
});

export const SummaryRequest = z.object({
  conversationId: z.string().min(1).max(100),
  language: Language,
  transcript: z.string().min(1).max(40_000),
});

export type ErrorCode = "rate_limited" | "spend_cap" | "bad_request" | "forbidden_origin" | "upstream";

export function json(status: number, body: object, headers: Record<string, string> = {}): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json", ...headers },
  });
}

export function preflight(request: Request, config: GuardConfig): Response {
  const cors = corsHeaders(request.headers.get("origin"), config);
  return new Response(null, { status: Object.keys(cors).length ? 204 : 403, headers: cors });
}

/** Metadata only: never the transcript. */
export function logRequest(entry: Record<string, string | number | boolean>) {
  console.log(JSON.stringify(entry));
}
