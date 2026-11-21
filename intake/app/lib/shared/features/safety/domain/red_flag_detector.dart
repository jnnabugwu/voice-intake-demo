import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/features/safety/domain/red_flag.dart';

/// A keyword pass over what the worker said, in English and Spanish. Runs
/// before any model call, with no network, so it works in demo mode and
/// offline. The proxy runs the same patterns as a second line
/// (`intake/proxy/lib/red_flags.ts`); both are tested on bench lines 1–21.
class RedFlagDetector {
  const RedFlagDetector();

  /// Both languages are always checked: workers mix them.
  RedFlag? detect(String text, {Language? language}) {
    final t = text.toLowerCase().replaceAll(RegExp('[’`]'), "'");
    for (final p in _crisis) {
      final m = p.firstMatch(t);
      if (m != null) return RedFlag(kind: RedFlagKind.crisis, reason: m.group(0)!);
    }
    for (final p in _emergency) {
      final m = p.firstMatch(t);
      if (m != null) return RedFlag(kind: RedFlagKind.emergency, reason: m.group(0)!);
    }
    return null;
  }

  static final _emergency = [
    RegExp(
      r"chest pain|pain in (my|the) chest|chest (hurts|is tight|tightness)|pressure in (my|the) chest|heart attack",
    ),
    RegExp(
      r"short(ness)? of breath|can'?t breathe|cannot breathe|trouble breathing|hard to breathe|difficulty breathing",
    ),
    RegExp(
      r"face (is )?droop|slurred speech|can'?t (move|feel) (my )?(arm|leg|face)|one side of my (face|body)|stroke",
    ),
    RegExp(r'dolor (en|de)( el)? pecho|me duele el pecho|presión en el pecho|ataque (al|del) corazón|infarto'),
    RegExp(r'me falta el aire|falta de aire|no puedo respirar|me cuesta respirar|dificultad para respirar'),
    RegExp(r'cara caída|no puedo mover (el brazo|la pierna)|derrame|habla arrastrada'),
    // New confusion (bench line 21) and anyone asking about the ER.
    RegExp(r'\bconfused\b|\bconfusion\b|disoriented|emergency room|\bthe er\b'),
    RegExp(r'confundid[oa]|confusión|desorientad[oa]|sala de emergencias?'),
  ];

  static final _crisis = [
    RegExp(
      r"kill myself|end my life|suicid|want to die|don'?t want to (be here|live|be alive)|hurt myself|self[- ]harm",
    ),
    RegExp(
      r'matarme|me (quiero|voy a) matar|quitarme la vida|suicid|quiero morir(me)?|no quiero (estar aquí|vivir|seguir viviendo)|hacerme daño',
    ),
  ];
}
