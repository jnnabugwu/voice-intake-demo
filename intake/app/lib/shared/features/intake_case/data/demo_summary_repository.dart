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
    final severity = _severityOf(lower);
    final symptoms = [
      for (final (pattern, label) in _symptoms)
        if (pattern.allMatches(lower).any((m) => !_negated(lower, m.start))) label,
    ];
    final medications = [
      for (final m in _medication.allMatches(lower))
        if (!_negated(lower, m.start)) ..._items(m.group(2)!),
    ];
    final allergies = [
      for (final m in _allergy.allMatches(lower))
        if (!_negated(lower, m.start)) ..._items(m.group(2)!),
    ];

    return IntakeSummary(
      chiefComplaint: workerLines.isEmpty ? null : workerLines.first,
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
    r"\b(i take|i'm taking|i am taking|tomo|estoy tomando)\s+([a-záéíóúñ0-9 ,]+?)" + _listEnd,
  );
  static final _allergy = RegExp(
    r"\b(allergic to|alérgic[oa] (?:a(?: la| el| los| las)?|al))\s+([a-záéíóúñ0-9 ,]+?)" + _listEnd,
  );

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
    final before = text.substring(start < 30 ? 0 : start - 30, start);
    // A clause ends at punctuation, "but", or the next worker line.
    final clause = before.split(RegExp(r'[.,;!?\n]|\bbut\b|\bpero\b')).last;
    return RegExp(r"\b(no|not|never|without|don'?t|doesn'?t|haven'?t|sin|nunca|tampoco)\b").hasMatch(clause);
  }

  static final _symptoms = <(RegExp, String)>[
    (RegExp(r'sore throat|throat|garganta'), 'sore throat'),
    (RegExp(r'swallow|tragar'), 'pain when swallowing'),
    (RegExp(r'fever|fiebre'), 'fever'),
    (RegExp(r'\bcough|\btos\b'), 'cough'),
    (RegExp(r'headache|dolor de cabeza'), 'headache'),
    (RegExp(r'nause|náusea|vomit|vómit'), 'nausea or vomiting'),
    (RegExp(r'dizz|mare'), 'dizziness'),
    (RegExp(r'swollen|swelling|hinchad'), 'swelling'),
    (RegExp(r'\brash\b|sarpullido|erupción'), 'rash'),
    (RegExp(r'back pain|dolor de espalda'), 'back pain'),
    (RegExp(r'chest pain|dolor en el pecho'), 'chest pain'),
    (RegExp(r'short of breath|trouble breathing|falta el aire|me cuesta respirar'), 'shortness of breath'),
  ];
}
