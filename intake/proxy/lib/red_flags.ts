/**
 * The proxy's own red-flag pass, run on the worker's newest message before any
 * model call. The app runs the same patterns first (RedFlagDetector); this is
 * defense in depth for any client that skips it. Both are tested against every
 * line of bench/references.json in both languages.
 */
export type RedFlagKind = "emergency" | "crisis";

/** Lowercase, straight quotes, no accents: speech engines and typing drop Spanish accents. */
export function fold(text: string): string {
  return text
    .toLowerCase()
    .replace(/[’`]/g, "'")
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "");
}

// Spanish determiners: "el pecho", "mi pecho", "su pecho", or none.
const DET = "(?:el |la |mi |su )?";

const EMERGENCY = [
  /chest pain|pain in (my|the) chest|chest (hurts|is tight|tightness)|pressure in (my|the) chest|heart attack/,
  /short(ness)? of breath|can'?t breathe|cannot breathe|trouble breathing|hard to breathe|difficulty breathing/,
  /face (is )?droop|drooping face|droopy face|slurred speech|slurring|numb(ness)? (in|on) (my )?(arm|leg|face)|can'?t (move|feel|lift) (my )?(arm|leg|face)|one side of my (face|body)|stroke/,
  new RegExp(`dolor (?:en|de) ${DET}pecho|me duele ${DET}pecho|presion en ${DET}pecho|ataque (?:al|del) corazon|infarto`),
  /me falta el aire|falta de aire|no puedo respirar|me cuesta respirar|dificultad para respirar/,
  new RegExp(`cara caida|no puedo mover ${DET}(?:brazo|pierna)|derrame|habla arrastrada|entumecid[oa]|adormecid[oa]`),
  // New confusion (bench line 21) and anyone asking about the ER.
  /\bconfused\b|\bconfusion\b|disoriented|emergency room|\bthe er\b/,
  /confundid[oa]|confusion|desorientad[oa]|sala de emergencias?/,
];

const CRISIS = [
  /kill myself|end my life|suicid|want to die|don'?t want to (be here|live|be alive)|hurt myself|self[- ]harm/,
  /matarme|me (quiero|voy a) matar|quitarme la vida|suicid|quiero morir(me)?|no quiero (estar aqui|vivir|seguir viviendo)|hacerme dano/,
];

/**
 * A denial just before the match, in the same clause: "no chest pain", "I
 * don't have chest pain", "sin dolor de pecho". Crisis phrases that contain
 * their own "no" ("no quiero vivir") start at the "no", so they aren't denied.
 */
function negated(text: string, start: number): boolean {
  // Only the clause the match is in ("no fever and can't breathe" is two clauses),
  // and only the few words right before it ("no", "don't have", "no tengo").
  const clause = text.slice(Math.max(0, start - 40), start).split(/[.,;!?]|\b(?:but|and|or|pero|y|o)\b/).pop() ?? "";
  const words = clause.trim().split(/\s+/).filter(Boolean).slice(-3);
  return words.some((w) => /^(no|not|never|without|don'?t|doesn'?t|didn'?t|haven'?t|sin|nunca|tampoco|ningun[oa]?)$/.test(w));
}

function firstHit(patterns: RegExp[], text: string): boolean {
  return patterns.some((p) => {
    const global = new RegExp(p.source, "g");
    for (const m of text.matchAll(global)) if (!negated(text, m.index ?? 0)) return true;
    return false;
  });
}

export function detectRedFlag(text: string): RedFlagKind | null {
  const t = fold(text);
  if (firstHit(CRISIS, t)) return "crisis";
  if (firstHit(EMERGENCY, t)) return "emergency";
  return null;
}
