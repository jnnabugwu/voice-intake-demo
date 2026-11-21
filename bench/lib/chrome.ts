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

const isTime = (x: unknown) => x === null || (typeof x === "number" && Number.isFinite(x));

export function isChromeExport(value: unknown): value is ChromeExport {
  const v = value as ChromeExport;
  return (
    !!v &&
    v.engine === "chrome-web-speech" &&
    typeof v.speaker === "string" &&
    typeof v.locale === "string" &&
    typeof v.browser === "string" &&
    typeof v.date === "string" &&
    Array.isArray(v.lines) &&
    v.lines.every(
      (l) =>
        !!l &&
        Number.isInteger(l.n) &&
        typeof l.transcript === "string" &&
        typeof l.micOnMs === "number" &&
        isTime(l.firstPartialMs) &&
        isTime(l.finalMs),
    )
  );
}
