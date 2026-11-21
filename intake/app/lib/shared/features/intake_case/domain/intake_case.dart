import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/features/intake_case/domain/intake_summary.dart';
import 'package:intake/shared/features/safety/domain/red_flag.dart';

part 'intake_case.freezed.dart';

enum TranscriptSpeaker { worker, assistant }

@freezed
abstract class TranscriptLine with _$TranscriptLine {
  const factory TranscriptLine({required TranscriptSpeaker speaker, required String text}) = _TranscriptLine;
}

/// Where a case stands. The worker's next step exists only once approved.
@freezed
sealed class CaseStatus with _$CaseStatus {
  const factory CaseStatus.awaitingReview() = AwaitingReview;
  const factory CaseStatus.approved({required String nextStep}) = Approved;

  /// The worker was shown 911 / 988. The physician still sees the case.
  const factory CaseStatus.escalated({required RedFlag flag}) = Escalated;
}

/// One worker's request for care: the only thing the two sides exchange.
@freezed
abstract class IntakeCase with _$IntakeCase {
  const factory IntakeCase({
    required String id,
    required Language language,
    required List<TranscriptLine> transcript,

    /// Null when the summary couldn't be built; the physician still has the transcript.
    IntakeSummary? summary,
    @Default(CaseStatus.awaitingReview()) CaseStatus status,
  }) = _IntakeCase;
}

/// The transcript as plain text, `Worker:` / `Assistant:` per line.
String transcriptText(List<TranscriptLine> lines) =>
    lines.map((l) => '${l.speaker == TranscriptSpeaker.worker ? 'Worker' : 'Assistant'}: ${l.text}').join('\n');
