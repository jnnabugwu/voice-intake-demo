import { createHash } from "node:crypto";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import type { FileTranscript } from "./assemblyai.js";
import { stem } from "./clips.js";
import type { FileEngine } from "./engines.js";
import type { Hypothesis, References } from "./report.js";

/**
 * Runs each available engine on every clip that exists. Transcripts are cached per
 * engine, keyed on the clip's bytes, so a rerun only pays for new or re-recorded clips.
 * An engine that can't run here, or fails on a clip, becomes a note in results.md.
 */
export async function runFileEngines(
  engines: FileEngine[],
  refs: References,
  clips: Map<string, string>,
  cacheRoot: string,
  log: (s: string) => void = (s) => process.stdout.write(s),
): Promise<{ hyps: Hypothesis[]; notes: string[] }> {
  const hyps: Hypothesis[] = [];
  const notes: string[] = [];
  for (const engine of engines) {
    const reason = await engine.unavailable();
    if (reason) {
      notes.push(`${engine.name} didn't run: ${reason}.`);
      continue;
    }
    const cacheDir = join(cacheRoot, engine.id);
    mkdirSync(cacheDir, { recursive: true });
    for (const speaker of refs.speakers) {
      for (const line of refs.lines) {
        const clip = clips.get(stem(speaker.id, line.n));
        if (!clip) continue;
        const digest = createHash("sha256").update(readFileSync(clip)).digest("hex").slice(0, 16);
        const cached = join(cacheDir, `${stem(speaker.id, line.n)}.${digest}.json`);
        let result: FileTranscript;
        if (existsSync(cached)) {
          result = JSON.parse(readFileSync(cached, "utf8"));
        } else {
          log(`${engine.name} ${stem(speaker.id, line.n)}… `);
          try {
            result = await engine.transcribe(clip, speaker);
          } catch (error) {
            const message = (error as Error).message.split("\n")[0];
            log(`failed: ${message}\n`);
            notes.push(`${engine.name} failed on ${stem(speaker.id, line.n)}: ${message}`);
            continue;
          }
          writeFileSync(cached, JSON.stringify(result));
          log(`${(result.processingMs / 1000).toFixed(1)} s\n`);
        }
        hyps.push({ engine: engine.name, speaker: speaker.id, n: line.n, text: result.text, processingMs: result.processingMs });
      }
    }
  }
  return { hyps, notes };
}

/**
 * Drops takes too short to hold a spoken line (an aborted or empty recording), so
 * no engine is scored on silence. `seconds` returns null when the length is unknown.
 */
export async function dropEmptyTakes(
  clips: Map<string, string>,
  seconds: (clip: string) => Promise<number | null>,
  minSeconds = 1.5,
): Promise<{ clips: Map<string, string>; notes: string[] }> {
  const kept = new Map<string, string>();
  const notes: string[] = [];
  for (const [name, path] of clips) {
    const s = await seconds(path);
    if (s != null && s < minSeconds) {
      notes.push(`${name} is ${s.toFixed(1)} s long, an empty take, so it isn't scored. Re-record it.`);
      continue;
    }
    kept.set(name, path);
  }
  return { clips: kept, notes };
}

/** Notes for speakers with some but not all lines, so scores are read in context. */
export function missingClipNotes(refs: References, clips: Map<string, string>): string[] {
  const notes: string[] = [];
  for (const speaker of refs.speakers) {
    const have = refs.lines.filter((l) => clips.has(stem(speaker.id, l.n)));
    if (have.length === 0) continue;
    for (const line of refs.lines) if (!clips.has(stem(speaker.id, line.n))) notes.push(`No clip for ${stem(speaker.id, line.n)}.`);
  }
  return notes;
}
