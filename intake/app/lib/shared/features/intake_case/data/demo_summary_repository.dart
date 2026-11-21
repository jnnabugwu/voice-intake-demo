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
        if (pattern.hasMatch(lower)) label,
    ];
    final medications = [for (final m in _medication.allMatches(lower)) m.group(2)!.trim()];
    final allergies = [for (final m in _allergy.allMatches(lower)) m.group(2)!.trim()];

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
        if (medications.isEmpty && !_denies.hasMatch(lower)) 'Any medications?',
        if (allergies.isEmpty && !_denies.hasMatch(lower)) 'Any allergies?',
      ],
      transcript: transcript,
    );
  }

  static final _duration = RegExp(
    r'\b(\d+|one|two|three|four|five|six|seven|a|few|couple|several|some|un|una|unos|unas|dos|tres|cuatro|cinco|varios|varias|pocos|pocas)\s+(of\s+)?(hours?|days?|weeks?|months?|horas?|d[ií]as?|semanas?|mes(es)?)\b'
    r'|\b(since yesterday|since last night|since this morning|desde ayer|desde anoche|desde esta mañana)\b',
  );

  static final _severityScale = RegExp(r'\b(10|[1-9])\s*(/|out of|de|sobre)\s*(10|ten|diez)\b');
  static final _bareNumber = RegExp(r'^\D*\b(10|[1-9])\b\D*$');

  static int? _severityOf(String lower) {
    final scaled = _severityScale.firstMatch(lower);
    if (scaled != null) return int.parse(scaled.group(1)!);
    // A short answer that is just a number ("About a 6.") answers the scale question.
    for (final line in lower.split(' \n ')) {
      final m = _bareNumber.firstMatch(line);
      if (m != null && line.length < 30) return int.parse(m.group(1)!);
    }
    return null;
  }

  static final _medication = RegExp(
    r"\b(i take|i'm taking|i am taking|taking|tomo|estoy tomando)\s+([a-záéíóúñ0-9 ]+?)(?=[,.;]| and | y |$)",
  );
  static final _allergy = RegExp(
    r"\b(allergic to|alérgic[oa] a(?: la| el)?)\s+([a-záéíóúñ0-9 ]+?)(?=[,.;]| and | y |$)",
  );
  static final _denies = RegExp(r'\b(no medications?|no allergies|nothing else|ningún medicamento|ninguna alergia)\b');

  static final _symptoms = <(RegExp, String)>[
    (RegExp(r'sore throat|throat|garganta'), 'sore throat'),
    (RegExp(r'swallow|tragar'), 'pain when swallowing'),
    (RegExp(r'fever|fiebre'), 'fever'),
    (RegExp(r'cough|tos\b'), 'cough'),
    (RegExp(r'headache|dolor de cabeza'), 'headache'),
    (RegExp(r'nause|náusea|vomit|vómit'), 'nausea or vomiting'),
    (RegExp(r'dizz|mare'), 'dizziness'),
    (RegExp(r'swollen|swelling|hinchad'), 'swelling'),
    (RegExp(r'rash|sarpullido|erupción'), 'rash'),
    (RegExp(r'back pain|dolor de espalda'), 'back pain'),
    (RegExp(r'chest pain|dolor en el pecho'), 'chest pain'),
    (RegExp(r'short of breath|trouble breathing|falta el aire|me cuesta respirar'), 'shortness of breath'),
  ];
}
