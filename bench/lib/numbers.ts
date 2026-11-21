/**
 * Spoken numbers to digits, in English and Spanish, applied to both the
 * reference and the hypothesis before scoring (bench/references.json
 * `scoring`). Covers what the script says: "one hundred and two" → 102,
 * "one fifty" → 150 (the way blood pressure is read), "sixty-eight" → 68,
 * "sesenta y ocho" → 68, "ciento cincuenta" → 150, "quinientos" → 500.
 */

const UNITS: Record<string, number> = {
  zero: 0, one: 1, two: 2, three: 3, four: 4, five: 5, six: 6, seven: 7, eight: 8, nine: 9,
  ten: 10, eleven: 11, twelve: 12, thirteen: 13, fourteen: 14, fifteen: 15, sixteen: 16,
  seventeen: 17, eighteen: 18, nineteen: 19,
  cero: 0, uno: 1, dos: 2, tres: 3, cuatro: 4, cinco: 5, seis: 6, siete: 7, ocho: 8, nueve: 9,
  diez: 10, once: 11, doce: 12, trece: 13, catorce: 14, quince: 15, dieciseis: 16, diecisiete: 17,
  dieciocho: 18, diecinueve: 19, veintiuno: 21, veintidos: 22, veintitres: 23, veinticuatro: 24,
  veinticinco: 25, veintiseis: 26, veintisiete: 27, veintiocho: 28, veintinueve: 29,
};

const TENS: Record<string, number> = {
  twenty: 20, thirty: 30, forty: 40, fifty: 50, sixty: 60, seventy: 70, eighty: 80, ninety: 90,
  veinte: 20, treinta: 30, cuarenta: 40, cincuenta: 50, sesenta: 60, setenta: 70, ochenta: 80, noventa: 90,
};

const HUNDREDS: Record<string, number> = {
  cien: 100, ciento: 100, doscientos: 200, doscientas: 200, trescientos: 300, trescientas: 300,
  cuatrocientos: 400, quinientos: 500, seiscientos: 600, setecientos: 700, ochocientos: 800, novecientos: 900,
};

const isUnit = (w?: string) => w !== undefined && w in UNITS;
const isTens = (w?: string) => w !== undefined && w in TENS;
const isNumberWord = (w?: string) =>
  w !== undefined && (isUnit(w) || isTens(w) || w in HUNDREDS || w === "hundred" || w === "thousand" || w === "mil");

/** Replaces each run of number words in [tokens] with its digits. */
export function wordsToDigits(tokens: string[]): string[] {
  const out: string[] = [];
  let i = 0;
  while (i < tokens.length) {
    const start = i;
    let total = 0;
    let current = 0;
    let used = false;
    // "a hundred" → 100.
    if (tokens[i] === "a" && tokens[i + 1] === "hundred") {
      current = 1;
      i++;
    }
    while (i < tokens.length) {
      const w = tokens[i]!;
      const next = tokens[i + 1];
      if (w in HUNDREDS) {
        current += HUNDREDS[w]!;
      } else if (w === "hundred" && (used || current > 0)) {
        current = (current || 1) * 100;
      } else if (w === "thousand" || w === "mil") {
        total += (current || 1) * 1000;
        current = 0;
      } else if (isTens(w)) {
        // "one fifty" (spoken 150): a unit followed straight by tens reads as hundreds.
        current = current > 0 && current < 10 && !tokens.slice(start, i).some((t) => t === "hundred" || t in HUNDREDS)
          ? current * 100 + TENS[w]!
          : current + TENS[w]!;
      } else if (isUnit(w)) {
        // A unit after a unit is a new number ("two two" stays two numbers).
        if (used && current % 10 !== 0 && !isTensJoin(tokens, i)) break;
        current += UNITS[w]!;
      } else if ((w === "and" || w === "y") && used && isNumberWord(next) && joins(tokens, i)) {
        // "one hundred and two", "sesenta y ocho": a joining word inside a number.
      } else {
        break;
      }
      used = true;
      i++;
    }
    if (used) {
      out.push(String(total + current));
    } else {
      out.push(tokens[i]!);
      i++;
    }
    if (i === start) i++; // safety
  }
  return out;
}

/** "and" joins only after "hundred"; "y" joins tens and units ("sesenta y ocho"). */
function joins(tokens: string[], i: number): boolean {
  const prev = tokens[i - 1];
  const next = tokens[i + 1];
  if (tokens[i] === "and") return prev === "hundred";
  return isTens(prev) && isUnit(next) && UNITS[next!]! < 10;
}

/** A unit right after "y" ("sesenta y ocho") continues the number. */
function isTensJoin(tokens: string[], i: number): boolean {
  return tokens[i - 1] === "y" || tokens[i - 1] === "and";
}
