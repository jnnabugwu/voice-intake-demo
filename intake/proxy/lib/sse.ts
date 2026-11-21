/** One server-sent event. Data is always JSON. */
export function sseEvent(event: "delta" | "done" | "refusal" | "error", data: object = {}): string {
  return `event: ${event}\ndata: ${JSON.stringify(data)}\n\n`;
}

export const sseHeaders = {
  "content-type": "text/event-stream; charset=utf-8",
  "cache-control": "no-cache, no-transform",
  "x-accel-buffering": "no",
} as const;
