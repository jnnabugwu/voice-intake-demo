import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/core/result.dart';
import 'package:intake/shared/features/intake_case/domain/case_repository.dart';
import 'package:intake/shared/features/intake_case/domain/intake_case.dart';
import 'package:intake/shared/features/intake_case/domain/summary_repository.dart';
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
    return _cases.submit(
      IntakeCase(
        id: conversationId,
        language: language,
        transcript: lines,
        summary: switch (summary) {
          Ok(:final value) => value,
          Err() => null,
        },
      ),
    );
  }
}
