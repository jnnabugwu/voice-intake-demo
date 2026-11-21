import { mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";
import { AssemblyAI } from "../lib/assemblyai.js";
import { isChromeExport } from "../lib/chrome.js";
import { renderResults, score, type References } from "../lib/report.js";

const refs = JSON.parse(readFileSync(new URL("../references.json", import.meta.url), "utf8")) as References;

describe("score + renderResults", () => {
  const line9en = refs.lines.find((l) => l.n === 9)!.en.text; // lisinopril
  const line1es = refs.lines.find((l) => l.n === 1)!.es.text;

  const rows = score(refs, [
    { engine: "Fake (batch)", speaker: "en_jn", n: 9, text: line9en.replace("lisinopril", "lysine april"), processingMs: 3000 },
    { engine: "Fake (batch)", speaker: "en_jn", n: 1, text: refs.lines[0]!.en.text, processingMs: 1000 },
    { engine: "Fake (live)", speaker: "es_mx", n: 1, text: line1es, firstWordMs: 400, finalMs: 2400 },
  ]);

  it("one row per engine × speaker, weak results included", () => {
    expect(rows.map((r) => `${r.engine}/${r.speaker}`)).toEqual(["Fake (batch)/en_jn", "Fake (live)/es_mx"]);
    const en = rows[0]!;
    expect(en.wer).toBeGreaterThan(0);
    expect(en.missed).toEqual([{ n: 9, terms: ["lisinopril"] }]);
    expect(en.medianProcessingMs).toBe(2000);
    expect(rows[1]!.wer).toBe(0);
    expect(rows[1]!.medianFirstWordMs).toBe(400);
  });

  it("the report labels live and batch latency separately and states the sample", () => {
    const md = renderResults(refs, rows, ["AssemblyAI didn't run: test."], "2026-11-20");
    expect(md).toContain("| Fake (batch) | en_jn (en-US) | 2 |");
    expect(md).toContain("Live: first word");
    expect(md).toContain("Batch: processing");
    expect(md).toContain("Don't compare live and batch numbers");
    expect(md).toContain("line 9 (lisinopril)");
    expect(md).toContain("21 scripted care-request lines per speaker");
    expect(md).toContain("never published");
    expect(md).toContain("AssemblyAI didn't run: test.");
  });
});

describe("AssemblyAI", () => {
  it("uploads, creates the transcript with the language, and polls until done", async () => {
    const dir = mkdtempSync(join(tmpdir(), "aai-"));
    const clip = join(dir, "es_mx_01.webm");
    writeFileSync(clip, "audio");
    const calls: { url: string; body?: string }[] = [];
    let polls = 0;
    let t = 0;
    const fake = async (url: string, init?: RequestInit) => {
      calls.push({ url, body: typeof init?.body === "string" ? init.body : undefined });
      const json = (b: object) => new Response(JSON.stringify(b), { status: 200 });
      if (url.endsWith("/upload")) return json({ upload_url: "https://cdn/x" });
      if (url.endsWith("/transcript")) return json({ id: "tx1", status: "queued" });
      polls++;
      t += 1000;
      return json(polls < 2 ? { status: "processing" } : { status: "completed", text: "Hola, necesito ver a un médico." });
    };
    const result = await new AssemblyAI("k", fake, () => t, 0).transcribe(clip, "es");
    expect(result).toEqual({ text: "Hola, necesito ver a un médico.", processingMs: 2000 });
    expect(JSON.parse(calls[1]!.body!)).toMatchObject({ audio_url: "https://cdn/x", language_code: "es" });
  });

  it("an error status or a failed request throws, so the runner can note it", async () => {
    const dir = mkdtempSync(join(tmpdir(), "aai-"));
    const clip = join(dir, "c.webm");
    writeFileSync(clip, "x");
    const failing = async () => new Response("nope", { status: 401 });
    await expect(new AssemblyAI("bad", failing, Date.now, 0).transcribe(clip, "en")).rejects.toThrow("401");
  });
});

describe("Chrome exports", () => {
  it("recognizes a /bench export", () => {
    expect(isChromeExport({ engine: "chrome-web-speech", speaker: "en_jn", lines: [] })).toBe(true);
    expect(isChromeExport({ engine: "other" })).toBe(false);
  });
});
