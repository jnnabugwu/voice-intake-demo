import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intake/shared/core/result.dart';
import 'package:intake/shared/features/intake_case/domain/case_repository.dart';
import 'package:intake/shared/features/intake_case/domain/intake_case.dart';
import 'package:intake/physician/features/case_review/presentation/review_event.dart';
import 'package:intake/physician/features/case_review/presentation/review_state.dart';

export 'package:intake/physician/features/case_review/presentation/review_event.dart';
export 'package:intake/physician/features/case_review/presentation/review_state.dart';

/// The physician's view of one case: summary, the next step being written,
/// and approval. The case itself lives in [CaseRepository].
class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  ReviewBloc(this._cases) : super(const ReviewState.loading()) {
    on<ReviewOpened>(_onOpened, transformer: restartable());
    on<ReviewCaseUpdated>(_onUpdated);
    on<NextStepDraftChanged>(_onDraftChanged);
    on<ApproveRequested>(_onApprove, transformer: droppable());
  }

  final CaseRepository _cases;

  /// What the draft starts as for a new case. The physician edits it; nothing
  /// reaches the worker until they approve.
  static const defaultNextStep = 'A clinician will call you today to talk about your symptoms.';

  Future<void> _onOpened(ReviewOpened event, Emitter<ReviewState> emit) async {
    final id = event.caseId;
    await emit.onEach<IntakeCase?>(
      id == null ? _cases.watchCurrent() : _cases.watch(id),
      onData: (c) => add(ReviewCaseUpdated(c)),
    );
  }

  void _onUpdated(ReviewCaseUpdated event, Emitter<ReviewState> emit) {
    final c = event.intakeCase;
    if (c == null) return emit(const ReviewState.noCase());
    final current = state;
    // Same case, same status: keep the physician's draft and any approve in flight.
    if (current is ReviewReady && current.intakeCase.id == c.id && current.intakeCase.status == c.status) {
      return emit(current.copyWith(intakeCase: c));
    }
    // Same case, newly approved: the editor shows what the worker now sees,
    // and an approve in flight stays in flight until its own result arrives.
    final approving = current is ReviewReady && current.intakeCase.id == c.id && current.approving;
    final draft = switch (c.status) {
      Approved(:final nextStep) => nextStep,
      _ => current is ReviewReady && current.intakeCase.id == c.id ? current.draft : defaultNextStep,
    };
    emit(ReviewState.ready(intakeCase: c, draft: draft, approving: approving));
  }

  void _onDraftChanged(NextStepDraftChanged event, Emitter<ReviewState> emit) {
    if (state case final ReviewReady ready) emit(ready.copyWith(draft: event.text, approveFailure: null));
  }

  Future<void> _onApprove(ApproveRequested event, Emitter<ReviewState> emit) async {
    final current = state;
    if (current is! ReviewReady || current.draft.trim().isEmpty) return;
    emit(current.copyWith(approving: true, approveFailure: null));
    final result = await _cases.approve(current.intakeCase.id, nextStep: current.draft);
    final latest = state;
    if (latest is! ReviewReady) return;
    emit(switch (result) {
      Ok() => latest.copyWith(approving: false),
      Err(:final failure) => latest.copyWith(approving: false, approveFailure: failure),
    });
  }
}
