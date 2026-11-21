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
    final t = fold(text);
    final crisis = _firstHit(_crisis, t);
    if (crisis != null) return RedFlag(kind: RedFlagKind.crisis, reason: crisis);
    final emergency = _firstHit(_emergency, t);
    if (emergency != null) return RedFlag(kind: RedFlagKind.emergency, reason: emergency);
    return null;
  }

  static String? _firstHit(List<RegExp> patterns, String text) {
    for (final p in patterns) {
      for (final m in p.allMatches(text)) {
        if (!_negated(text, m.start)) return m.group(0);
      }
    }
    return null;
  }

  /// A denial just before the match, in the same clause: "no chest pain",
  /// "I don't have chest pain", "sin dolor de pecho". Crisis phrases that
  /// contain their own "no" ("no quiero vivir") start at the "no", so they
  /// aren't denied.
  static bool _negated(String text, int start) {
    // Only the clause the match is in ("no fever and can't breathe" is two
    // clauses), and only the few words right before it ("no", "don't have").
    final before = text.substring(start < 40 ? 0 : start - 40, start);
    final clause = before.split(RegExp(r'[.,;!?]|\b(?:but|and|or|pero|y|o)\b')).last;
    final words = clause.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final near = words.length > 3 ? words.sublist(words.length - 3) : words;
    return near.any(
      RegExp(r"^(no|not|never|without|don'?t|doesn'?t|didn'?t|haven'?t|sin|nunca|tampoco|ningun[oa]?)$").hasMatch,
    );
  }

  /// Lowercase, curly quotes to straight, accents dropped: speech engines and
  /// typed input don't reliably add Spanish accents, so the patterns below are
  /// written without them.
  static String fold(String text) {
    var t = text.toLowerCase().replaceAll(RegExp('[’`]'), "'");
    _accents.forEach((from, to) => t = t.replaceAll(from, to));
    return t;
  }

  static const _accents = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u', 'ñ': 'n'};

  // Spanish possessives: "el pecho", "mi pecho", "su pecho", or none.
  static const _det = '(?:el |la |mi |su )?';

  static final _emergency = [
    RegExp(
      r"chest (pain|pressure|tightness|discomfort|hurts|is tight)|(pain|pressure|tightness) in (my |the )?chest|heart attack",
    ),
    RegExp(
      r"short(ness)? of breath|can'?t breathe|cannot breathe|trouble breathing|hard to breathe|difficulty breathing",
    ),
    RegExp(
      r"face (is )?droop|facial droop|drooping face|droopy face|slurred speech|slurring|numb(ness)? (in|on) (my )?(arm|leg|face)|(arm|leg|face) (is |feels |went )?numb|can'?t (move|feel|lift) (my )?(arm|leg|face)|one side of my (face|body)|stroke",
    ),
    RegExp(
      'dolor (?:en|de) ${_det}pecho|me duele ${_det}pecho|presion en ${_det}pecho|ataque (?:al|del) corazon|infarto',
    ),
    RegExp(r'me falta el aire|falta de aire|no puedo respirar|me cuesta respirar|dificultad para respirar'),
    RegExp('cara caida|no puedo mover $_det(?:brazo|pierna)|derrame|habla arrastrada|entumecid[oa]|adormecid[oa]'),
    // New confusion (bench line 21) and anyone asking about the ER.
    RegExp(r'\bconfused\b|\bconfusion\b|disoriented|emergency room|\bthe er\b'),
    RegExp(r'confundid[oa]|confusion|desorientad[oa]|sala de emergencias?'),
  ];

  static final _crisis = [
    RegExp(
      r"kill myself|end my life|suicid|want to die|(don'?t|do not) want to (be here|live|be alive)|(want|going|try(ing)?) to hurt myself|hurt myself on purpose|cut(ting)? myself|self[- ]harm",
    ),
    RegExp(
      r'overdos|took (a|the) whole bottle|took too many (pills|tablets)|swallowed (a bunch of|all (my|the)) pills',
    ),
    RegExp(
      r'matarme|me (quiero|voy a) matar|quitarme la vida|suicid|quiero morir(me)?|no quiero (estar aqui|vivir|seguir viviendo)|(quiero|voy a) hacerme dano|cortarme',
    ),
    RegExp(r'sobredosis|me tome (todo el frasco|todas las pastillas|demasiadas pastillas)'),
  ];
}
