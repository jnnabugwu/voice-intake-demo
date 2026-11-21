import { wordsToDigits } from "./numbers.js";

/**
 * Normalization from bench/references.json `scoring`, applied identically to
 * reference and hypothesis: lowercase, strip punctuation, spoken numbers to
 * digits. Decision: accents are folded too ("día" = "dia"). The bench scores
 * whether a word was recognized, not its spelling, and engines differ in
 * whether they write Spanish accents.
 */
export function normalize(text: string): string[] {
  const cleaned = text
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/['’`]/g, "")
    .replace(/[^\p{L}\p{N}\s]/gu, " ");
  return wordsToDigits(cleaned.split(/\s+/).filter(Boolean));
}

/** Word error rate: (substitutions + deletions + insertions) / reference words. */
export function wer(reference: string, hypothesis: string): number {
  const ref = normalize(reference);
  const hyp = normalize(hypothesis);
  if (ref.length === 0) return hyp.length === 0 ? 0 : 1;
  let prev = Array.from({ length: hyp.length + 1 }, (_, j) => j);
  for (let i = 1; i <= ref.length; i++) {
    const row = [i];
    for (let j = 1; j <= hyp.length; j++) {
      const cost = ref[i - 1] === hyp[j - 1] ? 0 : 1;
      row[j] = Math.min(prev[j]! + 1, row[j - 1]! + 1, prev[j - 1]! + cost);
    }
    prev = row;
  }
  return prev[hyp.length]! / ref.length;
}

/** A key term is found if any `|` variant appears, as whole words, in the normalized hypothesis. */
export function termFound(term: string, hypothesis: string): boolean {
  const hyp = ` ${normalize(hypothesis).join(" ")} `;
  return term.split("|").some((variant) => {
    const v = normalize(variant).join(" ");
    return v.length > 0 && hyp.includes(` ${v} `);
  });
}

/** The key terms the hypothesis missed. */
export function missedTerms(keyTerms: string[], hypothesis: string): string[] {
  return keyTerms.filter((t) => !termFound(t, hypothesis));
}
