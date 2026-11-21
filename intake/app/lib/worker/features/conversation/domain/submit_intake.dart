import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/core/result.dart';
import 'package:intake/shared/features/intake_case/domain/case_repository.dart';
import 'package:intake/shared/features/intake_case/domain/intake_case.dart';
import 'package:intake/shared/features/intake_case/domain/summary_repository.dart';
import 'package:intake/shared/features/safety/domain/red_flag.dart';
import 'package:intake/shared/features/safety/domain/red_flag_detector.dart';
import 'package:intake/worker/features/conversation/domain/turn.dart';
import 'package:meta/meta.dart';

/// Finishing an intake: the transcript becomes a summary, and the case goes
/// to the physician. A failed summary still submits the case, so the
/// physician can read the transcript.
class SubmitIntake {
  const SubmitIntake(this._summaries, this._cases);

  final SummaryRepository _summaries;
  final CaseRepository _cases;

  @useResult
  Future<Result<void>> call({
    required String conversationId,
    required Language language,
    required List<Turn> turns,

    /// Set when the chat stopped on a red flag.
    RedFlag? flag,
  }) async {
    final lines = [
      for (final t in turns)
        TranscriptLine(
          speaker: t.speaker == Speaker.worker ? TranscriptSpeaker.worker : TranscriptSpeaker.assistant,
          text: t.text,
        ),
    ];
    final summary = await _summaries.summarize(
      conversationId: conversationId,
      language: language,
      transcript: transcriptText(lines),
    );
    final built = switch (summary) {
      Ok(:final value) => value,
      Err() => null,
    };
    // A red flag in the summary escalates too, even if the keyword pass missed
    // it. The summary's flags are free text, so the detector picks the kind:
    // a crisis flag shows 988 first; anything else counts as an emergency.
    final escalation = flag ?? (built == null ? null : _fromSummary(built.redFlags));
    return _cases.submit(
      IntakeCase(id: conversationId, language: language, transcript: lines, summary: built, redFlag: escalation),
    );
  }

  static RedFlag? _fromSummary(List<String> redFlags) {
    if (redFlags.isEmpty) return null;
    final kind = const RedFlagDetector().detect(redFlags.join('. '))?.kind ?? RedFlagKind.emergency;
    return RedFlag(kind: kind, reason: redFlags.first);
  }
}
