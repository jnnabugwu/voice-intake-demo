/**
 * npm run bench: reads audio/ (repo root, gitignored), runs each file engine
 * on every clip it finds, merges the Chrome exports in bench/chrome/, and
 * writes bench/results.md.
 *
 * File-engine transcripts are cached in bench/.cache/ (gitignored), so a rerun
 * only pays for new clips. Delete the cache to re-transcribe.
 */
import { existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { AssemblyAI } from "./lib/assemblyai.js";
import { isChromeExport } from "./lib/chrome.js";
import { findClips, stem } from "./lib/clips.js";
import { renderResults, score, type Hypothesis, type References } from "./lib/report.js";

const here = dirname(fileURLToPath(import.meta.url));
const refs = JSON.parse(readFileSync(join(here, "references.json"), "utf8")) as References;
const notes: string[] = [];
const hyps: Hypothesis[] = [];

// Chrome Web Speech: live sessions exported from the app's /bench page.
const chromeDir = join(here, "chrome");
for (const file of existsSync(chromeDir) ? readdirSync(chromeDir).filter((f) => f.endsWith(".json")) : []) {
  const data = JSON.parse(readFileSync(join(chromeDir, file), "utf8"));
  if (!isChromeExport(data)) {
    notes.push(`Skipped \`chrome/${file}\`: not a /bench export.`);
    continue;
  }
  for (const l of data.lines) {
    hyps.push({
      engine: "Chrome Web Speech (live)",
      speaker: data.speaker,
      n: l.n,
      text: l.transcript,
      firstWordMs: l.firstPartialMs == null ? undefined : l.firstPartialMs - l.micOnMs,
      finalMs: l.finalMs == null ? undefined : l.finalMs - l.micOnMs,
    });
  }
  notes.push(`Chrome: ${data.browser}, ${data.locale}, ${data.date}.`);
}

// AssemblyAI on the recorded clips.
const clips = findClips(join(here, "..", "audio"));
const key = process.env.ASSEMBLYAI_API_KEY;
if (!key) {
  notes.push("AssemblyAI didn't run: `ASSEMBLYAI_API_KEY` isn't set in `bench/.env`.");
} else {
  const engine = new AssemblyAI(key);
  const cacheDir = join(here, ".cache", "assemblyai");
  mkdirSync(cacheDir, { recursive: true });
  for (const speaker of refs.speakers) {
    const lang = speaker.lang.startsWith("es") ? "es" : "en";
    for (const line of refs.lines) {
      const clip = clips.get(stem(speaker.id, line.n));
      if (!clip) continue;
      const cached = join(cacheDir, `${stem(speaker.id, line.n)}.json`);
      let result: { text: string; processingMs: number };
      if (existsSync(cached)) {
        result = JSON.parse(readFileSync(cached, "utf8"));
      } else {
        process.stdout.write(`AssemblyAI ${stem(speaker.id, line.n)}… `);
        try {
          result = await engine.transcribe(clip, lang);
        } catch (error) {
          console.log(`failed: ${(error as Error).message}`);
          notes.push(`AssemblyAI failed on ${stem(speaker.id, line.n)}: ${(error as Error).message}`);
          continue;
        }
        writeFileSync(cached, JSON.stringify(result));
        console.log(`${(result.processingMs / 1000).toFixed(1)} s`);
      }
      hyps.push({ engine: "AssemblyAI (batch)", speaker: speaker.id, n: line.n, text: result.text, processingMs: result.processingMs });
    }
  }
}

const missing = refs.speakers.filter((s) => !refs.lines.some((l) => clips.has(stem(s.id, l.n)))).map((s) => s.id);
if (missing.length) notes.push(`No clips yet for: ${missing.join(", ")}.`);

const rows = score(refs, hyps);
writeFileSync(join(here, "results.md"), renderResults(refs, rows, notes, new Date().toISOString().slice(0, 10)));
console.log(`Wrote bench/results.md: ${rows.length} engine × speaker rows.`);
