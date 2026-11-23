import { execFile } from "node:child_process";
import { cpSync, existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, statSync } from "node:fs";
import { homedir, tmpdir } from "node:os";
import { basename, dirname, join } from "node:path";
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
  /** Null when the engine can run for this speaker's locale; otherwise why not. Optional. */
  unsupported?(speaker: Speaker): Promise<string | null>;
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
 * Apple's newest on-device engine (SpeechAnalyzer, iOS 26 and macOS 26), run on
 * macOS through a small Swift CLI compiled on first use. The time measured covers
 * launching the CLI and setting up the transcriber for each clip, then transcribing;
 * the WAV conversion and the one-time model download happen before it.
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
        return `the Swift CLI didn't build (needs Xcode with the macOS 26+ SDK): ${compilerError(error)}`;
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

/** execFile's message starts with the command; the compiler's reason is in stderr. */
function compilerError(error: unknown): string {
  const stderr = String((error as { stderr?: unknown }).stderr ?? "");
  return (stderr.split("\n").find((l) => l.includes("error:")) ?? (error as Error).message.split("\n")[0]).trim();
}

/** One JSON line from the sfspeech app: {"text"} or {"ok"} on success, {"error"} otherwise. */
export function parseSfspeech(stdout: string): { text?: string; ok?: boolean } {
  const line = stdout.trim().split("\n").pop() ?? "";
  let parsed: { text?: unknown; ok?: unknown; error?: unknown };
  try {
    parsed = JSON.parse(line);
  } catch {
    throw new Error(line ? `unexpected output: ${line.slice(0, 120)}` : "no output (did the app start?)");
  }
  if (typeof parsed.error === "string") throw new Error(parsed.error);
  if (typeof parsed.text === "string") return { text: parsed.text };
  if (parsed.ok === true) return { ok: true };
  throw new Error(`unexpected output: ${line.slice(0, 120)}`);
}

/**
 * Apple's older engine (SFSpeechRecognizer), the one Flutter's `speech_to_text` and
 * React Native's `expo-speech-recognition` call on iOS today. Two rows: the packages'
 * default, where Apple picks server or on-device (so audio may go to Apple), and
 * on-device only (`onDevice: true`). Runs on macOS as a small app built on first use,
 * because macOS checks the launching app for a speech-recognition usage description;
 * the first run asks once for permission. The time measured includes launching it.
 */
export class SFSpeechEngine implements FileEngine {
  readonly name: string;
  readonly id: string;
  private readonly checked = new Map<string, string | null>();
  constructor(
    private readonly onDevice: boolean,
    private readonly source: string,
    private readonly plist: string,
    private readonly binDir: string,
    private readonly tmpDir: string,
  ) {
    this.name = onDevice ? "Apple SFSpeechRecognizer (on-device)" : "Apple SFSpeechRecognizer (default, may use Apple's servers)";
    this.id = onDevice ? "sfspeech-on-device" : "sfspeech-default";
  }

  private get app() {
    return join(this.binDir, "SFSpeech.app");
  }

  private get binary() {
    return join(this.app, "Contents", "MacOS", "sfspeech");
  }

  async unavailable() {
    if (process.platform !== "darwin") return "Apple's engines run on macOS only";
    if (!(await has("ffmpeg"))) return "`ffmpeg` isn't installed";
    const stale = (input: string) => !existsSync(this.binary) || statSync(this.binary).mtimeMs < statSync(input).mtimeMs;
    if (stale(this.source) || stale(this.plist)) {
      rmSync(this.app, { recursive: true, force: true });
      mkdirSync(dirname(this.binary), { recursive: true });
      cpSync(this.plist, join(this.app, "Contents", "Info.plist"));
      try {
        await run("xcrun", ["swiftc", "-parse-as-library", "-O", this.source, "-o", this.binary]);
        await run("codesign", ["--sign", "-", "--force", this.app]);
      } catch (error) {
        rmSync(this.app, { recursive: true, force: true });
        return `the Swift app didn't build (needs Xcode): ${compilerError(error)}`;
      }
    }
    return null;
  }

  async unsupported(speaker: Speaker) {
    if (!this.checked.has(speaker.lang)) {
      try {
        parseSfspeech(await this.launch(["check", speaker.lang]));
        this.checked.set(speaker.lang, null);
      } catch (error) {
        this.checked.set(speaker.lang, (error as Error).message);
      }
    }
    return this.checked.get(speaker.lang)!;
  }

  async transcribe(clip: string, speaker: Speaker): Promise<FileTranscript> {
    const wav = await toWav(clip, this.tmpDir);
    const started = Date.now();
    const { text } = parseSfspeech(await this.launch([speaker.lang, wav]));
    return { text: (text ?? "").trim(), processingMs: Date.now() - started };
  }

  /** `open -W` waits for the app; its exit code isn't the app's, so the result is read from stdout. */
  private async launch(args: string[]): Promise<string> {
    const dir = mkdtempSync(join(tmpdir(), "sfspeech-"));
    try {
      const out = join(dir, "out");
      const all = this.onDevice ? [...args, "--on-device"] : args;
      await run("open", ["-W", "-n", this.app, "--stdout", out, "--stderr", join(dir, "err"), "--args", ...all]);
      return existsSync(out) ? readFileSync(out, "utf8") : "";
    } finally {
      rmSync(dir, { recursive: true, force: true });
    }
  }
}

export const defaultWhisperModel = join(homedir(), ".cache", "whisper-models", "ggml-large-v3-turbo.bin");

/**
 * Whisper (large-v3-turbo by default), self-hosted with whisper.cpp (`brew install whisper-cpp`).
 * Open weights on our own hardware: no vendor, no per-minute bill. The time measured
 * includes loading the model, which a long-running server would do once.
 */
export class WhisperEngine implements FileEngine {
  readonly name: string;
  /** Named after the model file, so another `WHISPER_MODEL` gets its own row and cache. */
  readonly id: string;
  constructor(
    private readonly model: string,
    private readonly tmpDir: string,
  ) {
    const variant = basename(model).replace(/\.bin$/, "").replace(/^ggml-/, "");
    this.name = `Whisper ${variant} (self-hosted)`;
    this.id = `whisper-${variant}`;
  }

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
