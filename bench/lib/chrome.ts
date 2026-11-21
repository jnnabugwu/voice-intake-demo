/**
 * The JSON the app's /bench page exports (issue #15): one file per session,
 * dropped in bench/chrome/. Times are milliseconds since the page loaded.
 */
export interface ChromeExport {
  engine: "chrome-web-speech";
  speaker: string;
  locale: string;
  browser: string;
  date: string;
  lines: { n: number; transcript: string; micOnMs: number; firstPartialMs: number | null; finalMs: number | null }[];
}

export function isChromeExport(value: unknown): value is ChromeExport {
  const v = value as ChromeExport;
  return !!v && v.engine === "chrome-web-speech" && typeof v.speaker === "string" && Array.isArray(v.lines);
}
