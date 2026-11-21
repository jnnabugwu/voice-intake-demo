import { betaZodOutputFormat } from "@anthropic-ai/sdk/helpers/beta/zod";
import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";
import { IntakeSummary, ModelSummary } from "../contract/summary.js";
import { parseSummary, toApiMessages, totalUsage } from "../lib/claude.js";

describe("toApiMessages", () => {
  it("joins neighbours with the same role and drops a leading assistant turn", () => {
    expect(
      toApiMessages([
        { role: "assistant", text: "Hi" },
        { role: "user", text: "sore throat" },
        { role: "user", text: "three days" },
        { role: "assistant", text: "How bad?" },
        { role: "user", text: "6" },
      ]),
    ).toEqual([
      { role: "user", content: "sore throat\nthree days" },
      { role: "assistant", content: "How bad?" },
      { role: "user", content: "6" },
    ]);
  });
});

describe("totalUsage", () => {
  it("sums every attempt when a fallback ran", () => {
    expect(
      totalUsage({
        input_tokens: 100,
        output_tokens: 10,
        iterations: [
          { input_tokens: 100, output_tokens: 0 },
          { input_tokens: 120, output_tokens: 30, cache_read_input_tokens: 5 },
        ],
      }),
    ).toEqual({ input: 220, output: 30, cacheWrite: 0, cacheRead: 5 });
  });

  it("uses the top level when there are no iterations", () => {
    expect(totalUsage({ input_tokens: 7, output_tokens: 3, iterations: null })).toMatchObject({ input: 7, output: 3 });
  });
});

describe("summary contract", () => {
  it("the shared fixture matches the schema the proxy returns", () => {
    const fixture = JSON.parse(readFileSync(new URL("../contract/summary.example.json", import.meta.url), "utf8"));
    expect(IntakeSummary.parse(fixture)).toEqual(fixture);
  });

  it("the model schema converts to a structured-output format", () => {
    expect(() => betaZodOutputFormat(ModelSummary)).not.toThrow();
  });

  it("severity outside 1-10 is rejected client-side", () => {
    const base = { chief_complaint: null, duration: null, symptoms: [], medications: [], allergies: [], red_flags: [], open_questions: [] };
    expect(ModelSummary.safeParse({ ...base, severity: 11 }).success).toBe(false);
    expect(ModelSummary.safeParse({ ...base, severity: null }).success).toBe(true);
  });
});

describe("parseSummary", () => {
  const ok = { chief_complaint: "Cough", duration: null, severity: 4, symptoms: [], medications: [], allergies: [], red_flags: [], open_questions: [] };

  it("validates the structured output", () => {
    expect(parseSummary([{ type: "text", text: JSON.stringify(ok) }])).toEqual(ok);
  });

  it("returns null for invalid JSON, a bad severity, or no text", () => {
    expect(parseSummary([{ type: "text", text: "{not json" }])).toBeNull();
    expect(parseSummary([{ type: "text", text: JSON.stringify({ ...ok, severity: 12 }) }])).toBeNull();
    expect(parseSummary([{ type: "thinking" }])).toBeNull();
  });
});
