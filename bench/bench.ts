/**
 * npm run bench: reads audio/ (repo root, gitignored), runs each file engine
 * (AssemblyAI in the cloud, Apple's on-device engine, self-hosted Whisper) on
 * every clip it finds, merges the Chrome exports in bench/chrome/, and writes
 * bench/results.md. An engine that can't run here is skipped with a note.
 *
 * File-engine transcripts are cached in bench/.cache/ (gitignored), so a rerun
 * only pays for new clips. Delete the cache to re-transcribe.
 */
import { existsSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
import { arch, cpus, platform } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { isChromeExport } from "./lib/chrome.js";
import { findClips, stem } from "./lib/clips.js";
import { AppleEngine, AssemblyAIEngine, clipSeconds, defaultWhisperModel, SFSpeechEngine, WhisperEngine, type FileEngine } from "./lib/engines.js";
import { cutShort, renderResults, score, type Hypothesis, type References } from "./lib/report.js";
import { dropEmptyTakes, missingClipNotes, runFileEngines } from "./lib/run.js";

const here = dirname(fileURLToPath(import.meta.url));
const refs = JSON.parse(readFileSync(join(here, "references.json"), "utf8")) as References;
const notes: string[] = [];
const hyps: Hypothesis[] = [];

// Chrome Web Speech: live sessions exported from the app's /bench page.
const chromeDir = join(here, "chrome");
for (const file of existsSync(chromeDir) ? readdirSync(chromeDir).filter((f) => f.endsWith(".json")) : []) {
  let data: unknown;
  try {
    data = JSON.parse(readFileSync(join(chromeDir, file), "utf8"));
  } catch {
    notes.push(`Skipped \`chrome/${file}\`: not valid JSON.`);
    continue;
  }
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

// File engines on the recorded clips: cloud, Apple (newest and older engines), and self-hosted Whisper.
const recorded = findClips(join(here, "..", "audio"));
const found = await dropEmptyTakes(recorded, clipSeconds);
const clips = found.clips;
// Gaps are counted on what was recorded; an empty take already has its own note.
notes.push(...found.notes, ...missingClipNotes(refs, recorded));
const cacheRoot = join(here, ".cache");
const engines: FileEngine[] = [
  new AssemblyAIEngine(process.env.ASSEMBLYAI_API_KEY),
  new AppleEngine(join(here, "apple", "transcribe.swift"), join(cacheRoot, "bin"), join(cacheRoot, "wav")),
  new SFSpeechEngine(false, join(here, "apple", "sfspeech.swift"), join(here, "apple", "sfspeech.plist"), join(cacheRoot, "bin"), join(cacheRoot, "wav")),
  new SFSpeechEngine(true, join(here, "apple", "sfspeech.swift"), join(here, "apple", "sfspeech.plist"), join(cacheRoot, "bin"), join(cacheRoot, "wav")),
  new WhisperEngine(process.env.WHISPER_MODEL || defaultWhisperModel, join(cacheRoot, "wav")),
];
const ran = await runFileEngines(engines, refs, clips, cacheRoot);
hyps.push(...ran.hyps);
notes.push(...ran.notes);
const local = new Set(engines.filter((e) => !(e instanceof AssemblyAIEngine)).map((e) => e.name));
if (ran.hyps.some((h) => local.has(h.engine))) {
  notes.push(`Local engines ran on ${cpus()[0]?.model ?? "this machine"} (${platform()} ${arch()}).`);
}

// SFSpeechRecognizer: what its two modes did, read from the transcripts themselves.
const sfDefault = engines.find((e) => e instanceof SFSpeechEngine && e.id === "sfspeech-default")?.name;
const sfOnDevice = engines.find((e) => e instanceof SFSpeechEngine && e.id === "sfspeech-on-device")?.name;
for (const speaker of refs.speakers) {
  const texts = (engine: string | undefined) =>
    hyps.filter((h) => h.engine === engine && h.speaker === speaker.id).map((h) => `${h.n}:${h.text}`).join("\n");
  const a = texts(sfDefault);
  if (a && a === texts(sfOnDevice)) {
    notes.push(`SFSpeechRecognizer, ${speaker.id}: the default mode returned the same transcripts as on-device mode. Apple doesn't report which backend it used, so this doesn't show where the default ran.`);
  }
}
const short = sfOnDevice ? cutShort(refs, hyps, sfOnDevice) : [];
if (short.length) {
  notes.push(
    `SFSpeechRecognizer on-device returned under half the words of a long answer on ${short.join(", ")}. It resets after a pause, and its final result keeps only the last stretch of speech. It's scored as returned: an app that uses the final result gets the same.`,
  );
}

const noise = [...clips.keys()].filter((k) => k.endsWith("_noise"));
if (noise.length) notes.push(`${noise.length} background-noise clip(s) (\`_noise\`) were found and not scored; the table is the quiet reads.`);

const missing = refs.speakers.filter((s) => !refs.lines.some((l) => clips.has(stem(s.id, l.n)))).map((s) => s.id);
if (missing.length) notes.push(`No clips yet for: ${missing.join(", ")}.`);

const { rows, rejected } = score(refs, hyps);
for (const r of rejected) notes.push(`Not scored: ${r}.`);
writeFileSync(join(here, "results.md"), renderResults(refs, rows, notes, new Date().toISOString().slice(0, 10)));
console.log(`Wrote bench/results.md: ${rows.length} engine × speaker rows.`);
