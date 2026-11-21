import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/core/result.dart';
import 'package:intake/shared/features/intake_case/domain/intake_summary.dart';
import 'package:intake/shared/features/intake_case/domain/summary_repository.dart';

/// Builds the summary from the transcript with keyword rules, so demo mode
/// needs no keys. It records what was said in the worker's words and leaves
/// everything else null.
class DemoSummaryRepository implements SummaryRepository {
  const DemoSummaryRepository();

  @override
  Future<Result<IntakeSummary>> summarize({
    required String conversationId,
    required Language language,
    required String transcript,
  }) async => Ok(summarizeText(transcript, language));

  /// Public for tests.
  static IntakeSummary summarizeText(String transcript, Language language) {
    final workerLines = transcript
        .split('\n')
        .where((l) => l.startsWith('Worker: '))
        .map((l) => l.substring('Worker: '.length).trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final said = workerLines.join(' \n ');
    final lower = said.toLowerCase();

    final duration = _duration.firstMatch(lower)?.group(0);
    // The answer to the 1–10 question decides, even when it has no number;
    // an explicit "6 out of 10" or a bare number is used only if it wasn't asked.
    final (asked, answer) = _severityFromAnswer(transcript);
    final severity = answer ?? (asked ? _severityScaleOnly(lower) : _severityOf(lower));
    final symptoms = [
      for (final (pattern, label) in _symptoms)
        if (pattern.allMatches(lower).any((m) => !_negated(lower, m.start))) label,
    ];
    final medications = [
      for (final m in _medication.allMatches(lower))
        if (!_negated(lower, m.start)) ..._items(m.group(2)!).where(_looksLikeMedication),
    ];
    final allergies = [
      for (final m in _allergy.allMatches(lower))
        if (!_negated(lower, m.start)) ..._items(m.group(2)!),
    ];

    return IntakeSummary(
      chiefComplaint: _complaint(workerLines),
      duration: duration,
      severity: severity,
      symptoms: symptoms,
      medications: medications,
      allergies: allergies,
      language: language,
      openQuestions: [
        if (duration == null) 'How long has this been going on?',
        if (severity == null) 'How bad is it, 1 to 10?',
        if (medications.isEmpty && !_deniesMedications.hasMatch(lower)) 'Any medications?',
        if (allergies.isEmpty && !_deniesAllergies.hasMatch(lower)) 'Any allergies?',
      ],
      transcript: transcript,
    );
  }

  static final _duration = RegExp(
    r'\b(\d+|one|two|three|four|five|six|seven|a|few|couple|several|some|un|una|unos|unas|dos|tres|cuatro|cinco|varios|varias|pocos|pocas)\s+(of\s+)?(hours?|days?|weeks?|months?|horas?|d[ií]as?|semanas?|mes(es)?)\b'
    r'|\b(since yesterday|since last night|since this morning|desde ayer|desde anoche|desde esta mañana)\b',
  );

  static final _severityScale = RegExp(r'\b(10|[1-9])\s*(/|out of|de|sobre)\s*(10|ten|diez)\b');

  static const _numberWords = {
    'one': 1,
    'two': 2,
    'three': 3,
    'four': 4,
    'five': 5,
    'six': 6,
    'seven': 7,
    'eight': 8,
    'nine': 9,
    'ten': 10,
    'uno': 1,
    'una': 1,
    'dos': 2,
    'tres': 3,
    'cuatro': 4,
    'cinco': 5,
    'seis': 6,
    'siete': 7,
    'ocho': 8,
    'nueve': 9,
    'diez': 10,
  };

  /// The 1–10 question in either language, as the demo chat asks it.
  static final _scaleQuestion = RegExp(r'1 to 10|1 al 10');

  /// The worker's answer to the 1–10 question, read the way people talk:
  /// "seven seven, just a seven", "um, like an 8", "siete". The last number
  /// from 1 to 10 in the answer wins; anything else is left unsaid.
  static (bool, int?) _severityFromAnswer(String transcript) {
    var asked = false;
    var answered = false;
    for (final line in transcript.split('\n')) {
      if (line.startsWith('Assistant: ')) {
        asked = _scaleQuestion.hasMatch(line);
      } else if (line.startsWith('Worker: ') && asked) {
        answered = true;
        final words = line.substring('Worker: '.length).toLowerCase().split(RegExp(r'[^a-z0-9áéíóúñ]+'));
        final numbers = [
          for (final w in words)
            if (int.tryParse(w) case final n? when n >= 1 && n <= 10) n else ?_numberWords[w],
        ];
        if (numbers.isNotEmpty) return (true, numbers.last);
        asked = false;
      }
    }
    return (answered, null);
  }

  static int? _severityScaleOnly(String lower) {
    final scaled = _severityScale.firstMatch(lower);
    return scaled == null ? null : int.parse(scaled.group(1)!);
  }

  /// The first thing the worker said that is a complaint, minus greetings and
  /// their name: the physician needs the complaint, not the worker's name.
  /// Null when no line says anything but hello.
  static String? _complaint(List<String> lines) {
    for (final line in lines) {
      final c = line
          .replaceFirst(
            RegExp(
              r'^(hi|hello|hey|good (morning|afternoon|evening)|hola|buenos días|buenas( tardes| noches)?)[,.!]*\s*',
              caseSensitive: false,
            ),
            '',
          )
          .replaceFirst(
            RegExp(
              r'^(my name is|this is|me llamo|mi nombre es|soy)\s+[^\s,.!?]+(\s+[^\s,.!?]+)?\s*[,.]?\s*((and|y)\s+)?',
              caseSensitive: false,
            ),
            '',
          )
          .trim();
      if (c.isEmpty) continue;
      return c[0].toUpperCase() + c.substring(1);
    }
    return null;
  }

  /// A short answer that is only a number on the scale: "6", "about a 6", "maybe 7", "como un 5".
  static final _bareNumber = RegExp(
    r"^(about|around|maybe|probably|like|i'?d say|it'?s|it is|más o menos|como|tal vez|es|unos?)?\s*(an?|un|una|el)?\s*(10|[1-9])\s*[.!]?$",
  );

  static int? _severityOf(String lower) {
    final scaled = _severityScale.firstMatch(lower);
    if (scaled != null) return int.parse(scaled.group(1)!);
    // A short answer that is just a number ("About a 6.") answers the scale question.
    for (final line in lower.split(' \n ')) {
      final m = _bareNumber.firstMatch(line.trim());
      if (m != null) return int.parse(m.group(3)!);
    }
    return null;
  }

  /// A list ends at a sentence end, the next worker line, or a new clause
  /// ("and I'm allergic…", "y soy alérgica…"); "aspirin and ibuprofen" stays one list.
  static const _listEnd =
      r"(?=[.;!?]| \n |,?\s+(?:and|but)\s+(?:i|i'm|my)\b|,?\s+(?:y|pero)\s+(?:yo|soy|tengo|me|mi)\b|$)";

  static final _medication = RegExp(
    r"\b(i take|i'm taking|i am taking|tomo|estoy tomando)\s+([a-záéíóúñ0-9 ,'-]+?)" + _listEnd,
  );
  static final _allergy = RegExp(
    r"\b(allergic to|alérgic[oa] (?:a(?: la| el| los| las)?|al))\s+([a-záéíóúñ0-9 ,'-]+?)" + _listEnd,
  );

  /// "I take the bus", "I take care of my mom", "I take a break": ordinary
  /// phrases, not medications. A dose always counts.
  static bool _looksLikeMedication(String item) {
    if (RegExp(r'\d+\s*(mg|milligrams?|miligramos|ml|units?|unidades)\b').hasMatch(item)) return true;
    final first = item.split(' ').first;
    return !_notMedication.contains(first) && item.split(' ').length <= 4;
  }

  static const _notMedication = {
    'a',
    'an',
    'the',
    'my',
    'this',
    'that',
    'it',
    'care',
    'time',
    'off',
    'out',
    'up',
    'over',
    'some',
    'any',
    'nothing',
    'everything',
    'him',
    'her',
    'them',
    'el',
    'la',
    'los',
    'las',
    'mi',
    'un',
    'una',
    'agua',
    'cafe',
    'café',
    'nada',
    'todo',
  };

  /// "aspirin and ibuprofen", "aspirina, ibuprofeno y metformina" → each item.
  static List<String> _items(String list) => list
      .split(RegExp(r',\s*|\s+(?:and|or|y|o)\s+'))
      .map((i) => i.trim().replaceFirst(RegExp(r'^(?:la|el|los|las)\s+'), ''))
      .where((i) => i.isNotEmpty)
      .toList();
  static final _deniesMedications = RegExp(
    r"\b(no medications?|no medicine|don'?t take any(thing)?|not taking any(thing)?|no tomo (nada|ningún)|ningún medicamento)\b",
  );
  static final _deniesAllergies = RegExp(
    r"\b(no allergies|not allergic|no known allergies|no (soy|tengo) alérgic[oa]|no tengo alergias|ninguna alergia)\b",
  );

  /// True when a negation sits just before [start] in the same clause:
  /// "no fever", "not allergic to", "sin fiebre", "no tengo tos".
  static bool _negated(String text, int start) {
    final before = text.substring(start < 40 ? 0 : start - 40, start);
    // A clause ends at punctuation, a connective, or the next worker line, and
    // only the few words right before the match count ("no fever and a cough"
    // keeps the cough). Same rule as the red-flag detectors.
    final clause = before.split(RegExp(r'[.,;!?\n]|\b(?:but|and|or|pero|y|o|sin embargo)\b')).last;
    final words = clause.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final near = words.length > 3 ? words.sublist(words.length - 3) : words;
    return near.any(RegExp(r"^(no|not|never|without|don'?t|doesn'?t|haven'?t|sin|nunca|tampoco)$").hasMatch);
  }

  static final _symptoms = <(RegExp, String)>[
    (RegExp(r'sore throat|throat|garganta'), 'sore throat'),
    (RegExp(r'swallow|tragar'), 'pain when swallowing'),
    (RegExp(r'fever|fiebre'), 'fever'),
    (RegExp(r'\bcough|\btos\b'), 'cough'),
    (RegExp(r'headache|dolor de cabeza'), 'headache'),
    (RegExp(r'nause|náusea|vomit|vómit'), 'nausea or vomiting'),
    (RegExp(r'dizz|\bmare'), 'dizziness'),
    (RegExp(r'swollen|swelling|hinchad'), 'swelling'),
    (RegExp(r'\brash\b|sarpullido|erupción'), 'rash'),
    (RegExp(r'back pain|dolor de espalda'), 'back pain'),
    (RegExp(r'stomach|belly|tummy|abdomin|estómago|estomago|barriga|panza|abdomen'), 'stomach pain'),
    (RegExp(r'diarrh|diarrea'), 'diarrhea'),
    (RegExp(r'\bchills\b|escalofr'), 'chills'),
    (RegExp(r'\bear\b|earache|oído|oreja'), 'ear pain'),
    (RegExp(r'body ache|aches all over|me duele todo el cuerpo|dolor de cuerpo'), 'body aches'),
    (RegExp(r'tired|fatigue|exhausted|\bcansad'), 'fatigue'),
    (RegExp(r'chest pain|dolor en el pecho'), 'chest pain'),
    (RegExp(r'short of breath|trouble breathing|falta el aire|me cuesta respirar'), 'shortness of breath'),
  ];
}
