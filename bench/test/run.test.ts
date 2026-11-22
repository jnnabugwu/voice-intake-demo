import { mkdtempSync, readFileSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { describe, expect, it } from "vitest";
import { WhisperEngine, type FileEngine, type Speaker } from "../lib/engines.js";
import type { References } from "../lib/report.js";
import { dropEmptyTakes, missingClipNotes, runFileEngines } from "../lib/run.js";

const refs = JSON.parse(readFileSync(new URL("../references.json", import.meta.url), "utf8")) as References;

function clipsFor(dir: string, stems: string[]) {
  const clips = new Map<string, string>();
  for (const s of stems) {
    const path = join(dir, `${s}.webm`);
    writeFileSync(path, s);
    clips.set(s, path);
  }
  return clips;
}

class Fake implements FileEngine {
  readonly id: string;
  calls: string[] = [];
  constructor(
    readonly name: string,
    private readonly reason: string | null = null,
    private readonly failOn = new Set<string>(),
  ) {
    this.id = name.toLowerCase().replace(/\W+/g, "-");
  }
  async unavailable() {
    return this.reason;
  }
  async transcribe(clip: string, speaker: Speaker) {
    this.calls.push(`${speaker.id}:${speaker.lang}`);
    if (this.failOn.has(clip.split("/").pop()!)) throw new Error("boom\nstack");
    return { text: `heard ${clip.split("/").pop()}`, processingMs: 100 };
  }
}

describe("runFileEngines", () => {
  it("runs every available engine on every clip, with the speaker's locale", async () => {
    const dir = mkdtempSync(join(tmpdir(), "bench-"));
    const clips = clipsFor(dir, ["en_jn_01", "es_mx_01"]);
    const a = new Fake("Engine A");
    const { hyps, notes } = await runFileEngines([a], refs, clips, join(dir, "cache"), () => {});
    expect(hyps.map((h) => `${h.engine}/${h.speaker}/${h.n}`)).toEqual(["Engine A/en_jn/1", "Engine A/es_mx/1"]);
    expect(a.calls).toEqual(["en_jn:en-US", "es_mx:es-MX"]);
    expect(notes).toEqual([]);
  });

  it("an unavailable engine is a note, not a row", async () => {
    const dir = mkdtempSync(join(tmpdir(), "bench-"));
    const { hyps, notes } = await runFileEngines([new Fake("Cloud", "no key")], refs, clipsFor(dir, ["en_jn_01"]), dir, () => {});
    expect(hyps).toEqual([]);
    expect(notes).toEqual(["Cloud didn't run: no key."]);
  });

  it("caches per engine on the clip's bytes; a re-recorded clip is transcribed again", async () => {
    const dir = mkdtempSync(join(tmpdir(), "bench-"));
    const clips = clipsFor(dir, ["en_jn_01"]);
    const a = new Fake("Engine A");
    const b = new Fake("Engine B");
    await runFileEngines([a, b], refs, clips, join(dir, "cache"), () => {});
    await runFileEngines([a, b], refs, clips, join(dir, "cache"), () => {});
    expect(a.calls.length).toBe(1);
    expect(b.calls.length).toBe(1);
    writeFileSync(clips.get("en_jn_01")!, "re-recorded");
    await runFileEngines([a], refs, clips, join(dir, "cache"), () => {});
    expect(a.calls.length).toBe(2);
  });

  it("a failed clip is a note with the first line of the error, and the run goes on", async () => {
    const dir = mkdtempSync(join(tmpdir(), "bench-"));
    const clips = clipsFor(dir, ["en_jn_01", "en_jn_02"]);
    const { hyps, notes } = await runFileEngines([new Fake("Engine A", null, new Set(["en_jn_01.webm"]))], refs, clips, join(dir, "c"), () => {});
    expect(hyps.map((h) => h.n)).toEqual([2]);
    expect(notes).toEqual(["Engine A failed on en_jn_01: boom"]);
  });
});

describe("missingClipNotes", () => {
  it("lists gaps only for speakers who recorded something", () => {
    const clips = new Map(refs.lines.filter((l) => l.n !== 7).map((l) => [`es_mx_${String(l.n).padStart(2, "0")}`, "x"] as const));
    expect(missingClipNotes(refs, clips)).toEqual(["No clip for es_mx_07."]);
  });
});

describe("dropEmptyTakes", () => {
  it("drops takes under the minimum with a note; unknown lengths are kept", async () => {
    const clips = new Map([
      ["en_jn_19", "/a/en_jn_19.webm"],
      ["en_jn_20", "/a/en_jn_20.webm"],
      ["en_jn_21", "/a/en_jn_21.webm"],
    ]);
    const lengths: Record<string, number | null> = { "/a/en_jn_19.webm": 0.66, "/a/en_jn_20.webm": 5.6, "/a/en_jn_21.webm": null };
    const { clips: kept, notes } = await dropEmptyTakes(clips, async (p) => lengths[p]!);
    expect([...kept.keys()]).toEqual(["en_jn_20", "en_jn_21"]);
    expect(notes).toEqual(["en_jn_19 is 0.7 s long, an empty take, so it isn't scored. Re-record it."]);
  });
});

describe("WhisperEngine", () => {
  it("takes its row name and cache folder from the model file", () => {
    const turbo = new WhisperEngine("/m/ggml-large-v3-turbo.bin", "/tmp");
    const small = new WhisperEngine("/m/ggml-small.bin", "/tmp");
    expect([turbo.name, turbo.id]).toEqual(["Whisper large-v3-turbo (self-hosted)", "whisper-large-v3-turbo"]);
    expect([small.name, small.id]).toEqual(["Whisper small (self-hosted)", "whisper-small"]);
  });
});
