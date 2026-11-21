import 'package:flutter_test/flutter_test.dart';
import 'package:intake/shared/core/failure.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/core/result.dart';
import 'package:intake/shared/features/intake_case/data/in_memory_case_repository.dart';
import 'package:intake/shared/features/intake_case/domain/intake_case.dart';
import 'package:intake/shared/features/intake_case/domain/intake_summary.dart';
import 'package:intake/shared/features/intake_case/domain/summary_repository.dart';
import 'package:intake/worker/features/conversation/domain/submit_intake.dart';
import 'package:intake/worker/features/conversation/domain/turn.dart';

class _FailingSummaries implements SummaryRepository {
  String? transcript;

  @override
  Future<Result<IntakeSummary>> summarize({
    required String conversationId,
    required Language language,
    required String transcript,
  }) async {
    this.transcript = transcript;
    return const Err(NetworkFailure());
  }
}

void main() {
  test('a failed summary still submits the case with its transcript', () async {
    final summaries = _FailingSummaries();
    final cases = InMemoryCaseRepository();
    final result = await SubmitIntake(summaries, cases)(
      conversationId: 'c_1',
      language: Language.en,
      turns: const [
        Turn(id: 'u_1', speaker: Speaker.worker, text: 'sore throat', language: Language.en),
        Turn(id: 't_1', speaker: Speaker.assistant, text: 'How long?', language: Language.en),
      ],
    );
    expect(result, const Ok<void>(null));
    expect(summaries.transcript, 'Worker: sore throat\nAssistant: How long?');
    final submitted = await cases.watchCurrent().first;
    expect(submitted!.id, 'c_1');
    expect(submitted.summary, isNull);
    expect(submitted.status, const CaseStatus.awaitingReview());
  });
}
