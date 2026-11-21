import { expect, it } from "vitest";
import { sseEvent } from "../lib/sse.js";

it("frames one event per message with JSON data", () => {
  expect(sseEvent("delta", { text: "a\nb" })).toBe('event: delta\ndata: {"text":"a\\nb"}\n\n');
  expect(sseEvent("done")).toBe("event: done\ndata: {}\n\n");
});
