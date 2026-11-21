import 'package:intake/shared/core/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intake/physician/features/case_review/presentation/review_bloc.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/features/intake_case/data/in_memory_case_repository.dart';
import 'package:intake/shared/features/intake_case/domain/intake_case.dart';

const _case = IntakeCase(id: 'c_1', language: Language.en, transcript: []);

class _CountingCases extends InMemoryCaseRepository {
  int approvals = 0;

  @override
  Future<Result<void>> approve(String caseId, {required String nextStep}) {
    approvals++;
    return super.approve(caseId, nextStep: nextStep);
  }
}

void main() {
  test('no case, then the submitted case with the default draft', () async {
    final repo = InMemoryCaseRepository();
    final bloc = ReviewBloc(repo)..add(const ReviewOpened());
    await pumpEventQueue();
    expect(bloc.state, const ReviewState.noCase());
    await repo.submit(_case);
    await pumpEventQueue();
    expect(bloc.state, const ReviewState.ready(intakeCase: _case, draft: ReviewBloc.defaultNextStep));
    await bloc.close();
  });

  test('approve writes the edited step to the repository; a double tap approves once', () async {
    final repo = _CountingCases();
    await repo.submit(_case);
    final bloc = ReviewBloc(repo)..add(const ReviewOpened('c_1'));
    await pumpEventQueue();
    bloc
      ..add(const NextStepDraftChanged('Video visit at 3 pm'))
      ..add(const ApproveRequested())
      ..add(const ApproveRequested());
    await pumpEventQueue();
    final approved = _case.copyWith(status: const CaseStatus.approved(nextStep: 'Video visit at 3 pm'));
    expect(await repo.watch('c_1').first, approved);
    expect(repo.approvals, 1);
    expect(bloc.state, ReviewState.ready(intakeCase: approved, draft: 'Video visit at 3 pm'));
    await bloc.close();
  });

  test('an empty draft does not approve', () async {
    final repo = InMemoryCaseRepository();
    await repo.submit(_case);
    final bloc = ReviewBloc(repo)..add(const ReviewOpened());
    await pumpEventQueue();
    bloc
      ..add(const NextStepDraftChanged('  '))
      ..add(const ApproveRequested());
    await pumpEventQueue();
    expect((await repo.watch('c_1').first)!.status, const CaseStatus.awaitingReview());
    await bloc.close();
  });

  test('the approve lock holds through the case update the approval itself causes', () async {
    final repo = InMemoryCaseRepository();
    await repo.submit(_case);
    final bloc = ReviewBloc(repo)..add(const ReviewOpened('c_1'));
    await pumpEventQueue();
    final seen = <ReviewState>[];
    final sub = bloc.stream.listen(seen.add);
    bloc
      ..add(const NextStepDraftChanged('Video visit'))
      ..add(const ApproveRequested());
    await pumpEventQueue();
    await sub.cancel();
    final readies = seen.whereType<ReviewReady>().toList();
    // approving goes true once, then false once, with no early false in between.
    final flips = [
      for (var i = 1; i < readies.length; i++)
        if (readies[i].approving != readies[i - 1].approving) readies[i].approving,
    ];
    expect(flips, [true, false]);
    expect(readies.last.draft, 'Video visit');
    await bloc.close();
  });

  test('a Spanish case starts from a Spanish draft', () async {
    final repo = InMemoryCaseRepository();
    await repo.submit(const IntakeCase(id: 'c_es', language: Language.es, transcript: []));
    final bloc = ReviewBloc(repo)..add(const ReviewOpened());
    await pumpEventQueue();
    expect((bloc.state as ReviewReady).draft, ReviewBloc.defaultNextStepFor(Language.es));
    await bloc.close();
  });
}
