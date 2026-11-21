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
  /chest (pain|pressure|tightness|discomfort|hurts|is tight)|(pain|pressure|tightness) in (my |the )?chest|heart attack/,
  /short(ness)? of breath|can'?t breathe|cannot breathe|trouble breathing|hard to breathe|difficulty breathing/,
  /face (is )?droop|facial droop|drooping face|droopy face|slurred speech|slurring|numb(ness)? (in|on) (my )?(arm|leg|face)|(arm|leg|face) (is |feels |went )?numb|can'?t (move|feel|lift) (my )?(arm|leg|face)|one side of my (face|body)|stroke/,
  new RegExp(`dolor (?:en|de) ${DET}pecho|me duele ${DET}pecho|presion en ${DET}pecho|ataque (?:al|del) corazon|infarto`),
  /me falta el aire|falta de aire|no puedo respirar|me cuesta respirar|dificultad para respirar/,
  new RegExp(`cara caida|no puedo mover ${DET}(?:brazo|pierna)|derrame cerebral|(un|tuvo un|tiene un) derrame\\b|habla arrastrada|entumecid[oa]|adormecid[oa]`),
  // New confusion, as a symptom (bench line 21: "she's been very tired and
  // confused"), not "I'm confused about my bill"; and asking whether to go to
  // the ER, not mentioning a past ER visit.
  /\b(been|is|'s|seems|became|got|getting|gets) (very |really |more |suddenly |so )?((tired|sleepy|weak|dizzy|drowsy) and )?(confused|disoriented)\b(?! (about|by|with|on|how|what|why|where|over))|\b(new|sudden) confusion|\bdisoriented\b(?! (about|by))/,
  /\b(go|going|take (her|him|them|me|my \w+)|bring (her|him|them|me)) to the (emergency room|er)\b/,
  /\b(esta|anda|se ve|ha estado|se puso) (muy |mas |tan )?((cansad[oa]|debil|maread[oa]|somnolient[oa]) y )?(confundid[oa]|desorientad[oa])\b(?! (con|sobre|de|por))|confusion (repentina|nueva)|\btengo (mucha )?confusion\b(?! (con|sobre|de|por))/,
  /\b((la|lo|los|las|me) (llevo|llevamos|llevar)|(llevo|llevamos|llevar) a (mi|su|el|la) \w+) a (la sala de )?(emergencias|urgencias)|\b(ir|vamos|voy) a (la sala de )?(emergencias|urgencias)/,
];

const CRISIS = [
  /kill myself|end my life|i'?m suicidal|i am suicidal|feel(ing)? suicidal|suicidal (ideation|thoughts)|(thinking|thoughts?) (about|of) (suicide|killing myself)|commit suicide|(attempted|tried) (suicide|to kill myself)|suicide attempt|want to die|(don'?t|do not) want to (be here|live|be alive)|(want|going|try(ing)?) to (hurt|cut) myself|hurt myself on purpose|cutting myself|cut myself on purpose|self[- ]harm/,
  /overdos|took (a|the) whole bottle|took too many (pills|tablets)|swallowed (a bunch of|all (my|the)) pills/,
  /matarme|me (quiero|voy a) matar|quitarme la vida|suicidarme|ideas suicidas|ideacion suicida|pensamientos (suicidas|de suicidio)|pienso en el suicidio|intento de suicidio|intente suicidarme|quiero morir(me)?|no quiero (estar aqui|vivir|seguir viviendo)|(quiero|voy a) (hacerme dano|cortarme(?! el| la| las| los| un| una))/,
  /sobredosis|me tome (todo el frasco|todas las pastillas|demasiadas pastillas)/,
];

/**
 * A denial just before the match, in the same clause: "no chest pain", "I
 * don't have chest pain", "sin dolor de pecho". Crisis phrases that contain
 * their own "no" ("no quiero vivir") start at the "no", so they aren't denied.
 */
function negated(text: string, start: number): boolean {
  // Only the clause the match is in ("no fever and can't breathe" is two clauses),
  // and only the few words right before it ("no", "don't have", "no tengo").
  const clause = text.slice(Math.max(0, start - 40), start).split(/[.,;!?]|\b(?:but|and|or|pero|y|o|sin embargo)\b/).pop() ?? "";
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
