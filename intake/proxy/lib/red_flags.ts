/**
 * The proxy's own red-flag pass, run on the worker's newest message before any
 * model call. The app runs the same check first (RedFlagDetector); this one is
 * defense in depth for any client that skips it. Both are tested against lines
 * 20 and 21 of bench/references.json.
 */
export type RedFlagKind = "emergency" | "crisis";

const EMERGENCY = [
  /chest pain|pain in (my|the) chest|chest (hurts|is tight|tightness)|pressure in (my|the) chest|heart attack/,
  /short(ness)? of breath|can'?t breathe|cannot breathe|trouble breathing|hard to breathe|difficulty breathing/,
  /face (is )?droop|slurred speech|can'?t (move|feel) (my )?(arm|leg|face)|one side of my (face|body)|stroke/,
  /dolor (en|de)( el)? pecho|me duele el pecho|presión en el pecho|ataque (al|del) corazón|infarto/,
  /me falta el aire|falta de aire|no puedo respirar|me cuesta respirar|dificultad para respirar/,
  /cara caída|no puedo mover (el brazo|la pierna)|derrame|habla arrastrada/,
  // New confusion (line 21: an older adult with diabetes, confused since yesterday) and anyone asking about the ER.
  /\bconfused\b|\bconfusion\b|disoriented|emergency room|\bthe er\b/,
  /confundid[oa]|confusión|desorientad[oa]|sala de emergencias?/,
];

const CRISIS = [
  /kill myself|end my life|suicid|want to die|don'?t want to (be here|live|be alive)|hurt myself|self[- ]harm/,
  /matarme|me (quiero|voy a) matar|quitarme la vida|suicid|quiero morir(me)?|no quiero (estar aquí|vivir|seguir viviendo)|hacerme daño/,
];

export function detectRedFlag(text: string): RedFlagKind | null {
  const t = text.toLowerCase().replace(/[’`]/g, "'");
  if (CRISIS.some((r) => r.test(t))) return "crisis";
  if (EMERGENCY.some((r) => r.test(t))) return "emergency";
  return null;
}
