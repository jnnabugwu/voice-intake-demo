import { mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";
import { findClips, stem } from "../lib/clips.js";
import { missedTerms, normalize, termFound, wer } from "../lib/scoring.js";

type Side = { text: string; key_terms: string[] };
const refs = JSON.parse(readFileSync(new URL("../references.json", import.meta.url), "utf8")) as {
  lines: { n: number; en: Side; es: Side }[];
};

describe("the script scores perfectly against itself", () => {
  for (const line of refs.lines) {
    for (const lang of ["en", "es"] as const) {
      it(`line ${line.n} ${lang}`, () => {
        const { text, key_terms } = line[lang];
        expect(wer(text, text)).toBe(0);
        expect(missedTerms(key_terms, text)).toEqual([]);
      });
    }
  }
});

describe("normalize", () => {
  it.each([
    ["My throat has been sore for three days.", "my throat has been sore for 3 days"],
    ["a fever of one hundred and two", "a fever of 102"],
    ["one fifty over ninety-five", "150 over 95"],
    ["She's sixty-eight and has type two diabetes", "shes 68 and has type 2 diabetes"],
    ["I paid $45 at urgent care", "i paid 45 at urgent care"],
    ["two hundred and ten after lunch", "210 after lunch"],
    ["five hundred milligrams, twice a day", "500 milligrams twice a day"],
    ["Tiene sesenta y ocho años", "tiene 68 anos"],
    ["ciento cincuenta sobre noventa y cinco", "150 sobre 95"],
    ["en doscientos diez después", "en 210 despues"],
    ["quinientos miligramos, dos veces al día", "500 miligramos 2 veces al dia"],
    ["peso unas ciento ochenta libras", "peso unas 180 libras"],
    ["150/95", "150 95"],
  ])("%s", (input, expected) => {
    expect(normalize(input).join(" ")).toBe(expected);
  });

  it("joining words only join numbers", () => {
    expect(normalize("pain and two days").join(" ")).toBe("pain and 2 days");
    expect(normalize("ella y tres").join(" ")).toBe("ella y 3");
  });
});

describe("wer", () => {
  it("counts substitutions, deletions and insertions over reference words", () => {
    expect(wer("take ten milligrams", "take 10 milligrams")).toBe(0);
    expect(wer("take ten milligrams", "take milligrams")).toBeCloseTo(1 / 3);
    expect(wer("take ten milligrams", "I take ten milligrams daily")).toBeCloseTo(2 / 3);
    expect(wer("take ten milligrams", "bake ten milligrams")).toBeCloseTo(1 / 3);
  });
});

describe("key terms", () => {
  it("any variant counts, as whole words, after normalization", () => {
    expect(termFound("three days|3 days", "for 3 days")).toBe(true);
    expect(termFound("102|one hundred and two", "a fever of a hundred and two")).toBe(true);
    expect(termFound("sore throat|throat", "my throats")).toBe(false);
    expect(termFound("tres días|3 días", "desde hace tres dias")).toBe(true);
    expect(missedTerms(["lisinopril", "blood pressure"], "I take lysinopril for my blood pressure")).toEqual(["lisinopril"]);
  });
});

describe("clips", () => {
  it("matches by stem with any audio extension, newest naming from the recorder", () => {
    const dir = mkdtempSync(join(tmpdir(), "clips-"));
    for (const f of ["es_mx_01.webm", "en_jn_02.mp4", "es_cu_03.m4a", "notes.txt", "notes.mp3", "es_mx_01_noise.webm"]) {
      writeFileSync(join(dir, f), "");
    }
    const clips = findClips(dir);
    expect(clips.get(stem("es_mx", 1))).toBe(join(dir, "es_mx_01.webm"));
    expect(clips.get(stem("en_jn", 2))).toBe(join(dir, "en_jn_02.mp4"));
    expect(clips.has("notes")).toBe(false); // .mp3 too: not a {speaker}_{NN} stem
    expect(clips.has("es_mx_01_noise")).toBe(true);
    expect(findClips(join(dir, "missing")).size).toBe(0);
  });
});
