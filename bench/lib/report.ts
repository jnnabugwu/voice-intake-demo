import { missedTerms, normalize, wer } from "./scoring.js";

export interface Side {
  text: string;
  key_terms: string[];
}
export interface References {
  speakers: { id: string; lang: string; who: string }[];
  lines: { n: number; en: Side; es: Side; expect_red_flag: boolean }[];
}

/** One engine's transcript of one line by one speaker. */
export interface Hypothesis {
  engine: string;
  speaker: string;
  n: number;
  text: string;
  /** Live: mic on to first partial word. */
  firstWordMs?: number;
  /** Live: mic on to final text. */
  finalMs?: number;
  /** Batch: upload to finished transcript. */
  processingMs?: number;
}

export interface Row {
  engine: string;
  speaker: string;
  lines: number;
  wer: number;
  termMissRate: number;
  missed: { n: number; terms: string[] }[];
  medianFirstWordMs?: number;
  medianFinalMs?: number;
  medianProcessingMs?: number;
}

const median = (xs: number[]) => {
  if (xs.length === 0) return undefined;
  const s = [...xs].sort((a, b) => a - b);
  const m = Math.floor(s.length / 2);
  return s.length % 2 ? s[m]! : (s[m - 1]! + s[m]!) / 2;
};

const langOf = (refs: References, speaker: string): "en" | "es" =>
  refs.speakers.find((s) => s.id === speaker)?.lang.startsWith("es") ? "es" : "en";

/** Scores every engine × speaker that has transcripts. WER is pooled over words. */
export function score(refs: References, hyps: Hypothesis[]): Row[] {
  const groups = new Map<string, Hypothesis[]>();
  for (const h of hyps) groups.set(`${h.engine}\u0000${h.speaker}`, [...(groups.get(`${h.engine}\u0000${h.speaker}`) ?? []), h]);
  const rows: Row[] = [];
  for (const group of groups.values()) {
    const { engine, speaker } = group[0]!;
    const lang = langOf(refs, speaker);
    let errors = 0;
    let words = 0;
    let terms = 0;
    const missed: Row["missed"] = [];
    for (const h of group.sort((a, b) => a.n - b.n)) {
      const ref = refs.lines.find((l) => l.n === h.n)?.[lang];
      if (!ref) continue;
      // wer() divides by normalized words ("one hundred and two" is one word, 102), so pool on the same count.
      const refWords = normalize(ref.text).length;
      errors += wer(ref.text, h.text) * refWords;
      words += refWords;
      terms += ref.key_terms.length;
      const m = missedTerms(ref.key_terms, h.text);
      if (m.length) missed.push({ n: h.n, terms: m.map((t) => t.split("|")[0]!) });
    }
    rows.push({
      engine,
      speaker,
      lines: group.length,
      wer: words ? errors / words : 0,
      termMissRate: terms ? missed.reduce((s, m) => s + m.terms.length, 0) / terms : 0,
      missed,
      medianFirstWordMs: median(group.flatMap((h) => (h.firstWordMs == null ? [] : [h.firstWordMs]))),
      medianFinalMs: median(group.flatMap((h) => (h.finalMs == null ? [] : [h.finalMs]))),
      medianProcessingMs: median(group.flatMap((h) => (h.processingMs == null ? [] : [h.processingMs]))),
    });
  }
  return rows.sort((a, b) => a.speaker.localeCompare(b.speaker) || a.engine.localeCompare(b.engine));
}

const pct = (x: number) => `${(x * 100).toFixed(1)}%`;
const secs = (ms?: number) => (ms == null ? "n/a" : `${(ms / 1000).toFixed(2)} s`);

/** results.md: the table, every engine and speaker that ran, weak results included. */
export function renderResults(refs: References, rows: Row[], notes: string[], date: string): string {
  const who = (id: string) => refs.speakers.find((s) => s.id === id);
  const out = [
    "# Speech bench results",
    "",
    `_Generated ${date} by \`npm run bench\` from \`bench/references.json\`._`,
    "",
    "| Engine | Speaker | Lines | WER | Medical-term miss rate | Live: first word | Live: final text | Batch: processing |",
    "|---|---|---|---|---|---|---|---|",
    ...rows.map(
      (r) =>
        `| ${r.engine} | ${r.speaker} (${who(r.speaker)?.lang ?? "?"}) | ${r.lines} | ${pct(r.wer)} | ${pct(r.termMissRate)} | ${secs(r.medianFirstWordMs)} | ${secs(r.medianFinalMs)} | ${secs(r.medianProcessingMs)} |`,
    ),
    "",
    "Latency columns are medians and measure different things. **Live** (Chrome Web Speech, read aloud on `/bench`): time from mic on to the first partial word, and to the final text. **Batch** (file engines): wall-clock time from upload to finished transcript, including queueing. Don't compare live and batch numbers with each other.",
    "",
    "## Missed medical terms",
    "",
    ...(rows.every((r) => r.missed.length === 0)
      ? ["None."]
      : rows.flatMap((r) =>
          r.missed.length === 0
            ? []
            : [`**${r.engine}, ${r.speaker}:** ${r.missed.map((m) => `line ${m.n} (${m.terms.join(", ")})`).join("; ")}`, ""],
        )),
    "",
    "## About this sample",
    "",
    `- ${refs.lines.length} scripted care-request lines per speaker, read aloud: one speaker per accent (${refs.speakers.map((s) => `${s.id}: ${s.lang}`).join(", ")}). Read speech is easier than real conversations. Treat these numbers as directional, not definitive.`,
    "- WER and term matching follow the `scoring` rule in `references.json`: lowercase, punctuation stripped, spoken numbers as digits, accents folded. A key term counts as found if any accepted variant appears.",
    "- Scores only. The recordings stay private and are never published.",
    ...notes.map((n) => `- ${n}`),
    "",
  ];
  return out.join("\n");
}
