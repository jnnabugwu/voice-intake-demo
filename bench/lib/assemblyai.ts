import { readFile } from "node:fs/promises";

/** One clip's result from a file-based engine. */
export interface FileTranscript {
  text: string;
  /** Upload + queue + transcription, wall clock. A batch measure, not live latency. */
  processingMs: number;
}

export type FetchLike = (url: string, init?: RequestInit) => Promise<Response>;

/**
 * AssemblyAI over its REST API (v2): upload the clip, create a transcript,
 * poll until it completes. `fetch` and the clock are injectable for tests.
 */
export class AssemblyAI {
  constructor(
    private readonly apiKey: string,
    private readonly fetchFn: FetchLike = fetch,
    private readonly now: () => number = Date.now,
    private readonly pollMs = 1500,
    /** Give up on one clip after this long, so a stuck job can't stall the run. */
    private readonly deadlineMs = 10 * 60_000,
  ) {}

  static readonly base = "https://api.assemblyai.com/v2";

  async transcribe(path: string, language: "en" | "es"): Promise<FileTranscript> {
    const started = this.now();
    const auth = { authorization: this.apiKey };

    const upload = await this.json(`${AssemblyAI.base}/upload`, {
      method: "POST",
      headers: { ...auth, "content-type": "application/octet-stream" },
      body: await readFile(path),
    });
    const job = await this.json(`${AssemblyAI.base}/transcript`, {
      method: "POST",
      headers: { ...auth, "content-type": "application/json" },
      body: JSON.stringify({
        audio_url: upload.upload_url,
        language_code: language === "en" ? "en_us" : "es",
        punctuate: true,
        format_text: true,
      }),
    });

    for (;;) {
      if (this.now() - started > this.deadlineMs) throw new Error(`AssemblyAI: no result after ${this.deadlineMs / 1000} s`);
      const status = await this.json(`${AssemblyAI.base}/transcript/${job.id}`, { headers: auth });
      if (status.status === "completed") return { text: String(status.text ?? ""), processingMs: this.now() - started };
      if (status.status === "error") throw new Error(`AssemblyAI: ${status.error ?? "transcription failed"}`);
      await new Promise((r) => setTimeout(r, this.pollMs));
    }
  }

  private async json(url: string, init: RequestInit): Promise<Record<string, any>> {
    // Each request gets its own timeout, so a fetch that never settles fails instead.
    const res = await this.fetchFn(url, { ...init, signal: init.signal ?? AbortSignal.timeout(120_000) });
    if (!res.ok) throw new Error(`AssemblyAI ${res.status} on ${new URL(url).pathname}`);
    return (await res.json()) as Record<string, any>;
  }
}
