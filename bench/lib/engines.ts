import { execFile } from "node:child_process";
import { existsSync, mkdirSync, statSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { promisify } from "node:util";
import { AssemblyAI, type FileTranscript } from "./assemblyai.js";

const run = promisify(execFile);

export interface Speaker {
  id: string;
  /** BCP-47, e.g. en-US, es-MX. */
  lang: string;
}

/** An engine that transcribes recorded clips. Each one is a row per speaker in results.md. */
export interface FileEngine {
  /** Row label in results.md. */
  readonly name: string;
  /** Cache folder under bench/.cache/. */
  readonly id: string;
  /** Null when the engine can run here; otherwise the reason it was skipped. */
  unavailable(): Promise<string | null>;
  transcribe(clip: string, speaker: Speaker): Promise<FileTranscript>;
}

const twoLetter = (lang: string): "en" | "es" => (lang.startsWith("es") ? "es" : "en");

/** Clips arrive as .webm or .mp4; the local engines read 16 kHz mono WAV. */
async function toWav(clip: string, tmpDir: string): Promise<string> {
  mkdirSync(tmpDir, { recursive: true });
  const out = join(tmpDir, `${clip.split("/").pop()!.replace(/\.[^.]+$/, "")}.wav`);
  await run("ffmpeg", ["-v", "error", "-y", "-i", clip, "-ac", "1", "-ar", "16000", out]);
  return out;
}

/** A clip's length from ffprobe, or null when ffprobe isn't available or can't read it. */
export async function clipSeconds(clip: string): Promise<number | null> {
  try {
    const { stdout } = await run("ffprobe", ["-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", clip]);
    const s = Number.parseFloat(stdout);
    return Number.isFinite(s) ? s : null;
  } catch {
    return null;
  }
}

async function has(command: string): Promise<boolean> {
  try {
    await run("which", [command]);
    return true;
  } catch {
    return false;
  }
}

/** Cloud, batch: upload, queue, transcribe. Needs ASSEMBLYAI_API_KEY. */
export class AssemblyAIEngine implements FileEngine {
  readonly name = "AssemblyAI (cloud)";
  readonly id = "assemblyai";
  constructor(private readonly key: string | undefined) {}
  async unavailable() {
    return this.key ? null : "`ASSEMBLYAI_API_KEY` isn't set in `bench/.env`";
  }
  transcribe(clip: string, speaker: Speaker) {
    return new AssemblyAI(this.key!).transcribe(clip, twoLetter(speaker.lang));
  }
}

/**
 * Apple's on-device engine (SpeechAnalyzer), the one an iPhone build uses, run on
 * macOS through a small Swift CLI compiled on first use. The time measured is the
 * transcription only: the WAV conversion and the one-time model download happen first.
 */
export class AppleEngine implements FileEngine {
  readonly name = "Apple SpeechAnalyzer (on-device)";
  readonly id = "apple";
  private readonly prepared = new Set<string>();
  constructor(
    private readonly source: string,
    private readonly binDir: string,
    private readonly tmpDir: string,
  ) {}

  private get binary() {
    return join(this.binDir, "apple-transcribe");
  }

  async unavailable() {
    if (process.platform !== "darwin") return "Apple's engine runs on macOS only";
    if (!(await has("ffmpeg"))) return "`ffmpeg` isn't installed";
    if (!existsSync(this.binary) || statSync(this.binary).mtimeMs < statSync(this.source).mtimeMs) {
      mkdirSync(this.binDir, { recursive: true });
      try {
        await run("xcrun", ["swiftc", "-parse-as-library", "-O", this.source, "-o", this.binary]);
      } catch (error) {
        return `the Swift CLI didn't build (needs Xcode with the macOS 26+ SDK): ${(error as Error).message.split("\n")[0]}`;
      }
    }
    return null;
  }

  async transcribe(clip: string, speaker: Speaker): Promise<FileTranscript> {
    if (!this.prepared.has(speaker.lang)) {
      await run(this.binary, ["prepare", speaker.lang]);
      this.prepared.add(speaker.lang);
    }
    const wav = await toWav(clip, this.tmpDir);
    const started = Date.now();
    const { stdout } = await run(this.binary, [speaker.lang, wav]);
    return { text: stdout.trim(), processingMs: Date.now() - started };
  }
}

export const defaultWhisperModel = join(homedir(), ".cache", "whisper-models", "ggml-large-v3-turbo.bin");

/**
 * Whisper large-v3-turbo, self-hosted with whisper.cpp (`brew install whisper-cpp`).
 * Open weights on our own hardware: no vendor, no per-minute bill. The time measured
 * includes loading the model, which a long-running server would do once.
 */
export class WhisperEngine implements FileEngine {
  readonly name = "Whisper large-v3-turbo (self-hosted)";
  readonly id = "whisper-large-v3-turbo";
  constructor(
    private readonly model: string,
    private readonly tmpDir: string,
  ) {}

  async unavailable() {
    if (!(await has("whisper-cli"))) return "`whisper-cli` isn't installed (`brew install whisper-cpp`)";
    if (!(await has("ffmpeg"))) return "`ffmpeg` isn't installed";
    if (!existsSync(this.model)) return `no model at \`${this.model.replace(homedir(), "~")}\` (set \`WHISPER_MODEL\`)`;
    return null;
  }

  async transcribe(clip: string, speaker: Speaker): Promise<FileTranscript> {
    const wav = await toWav(clip, this.tmpDir);
    const started = Date.now();
    const { stdout } = await run("whisper-cli", ["-m", this.model, "-f", wav, "-l", twoLetter(speaker.lang), "-nt", "-np"], {
      maxBuffer: 1 << 20,
    });
    return { text: stdout.replace(/\s+/g, " ").trim(), processingMs: Date.now() - started };
  }
}
