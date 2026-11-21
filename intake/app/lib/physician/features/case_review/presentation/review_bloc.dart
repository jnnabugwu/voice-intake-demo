import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intake/shared/core/language.dart';
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
  (String, String)? _lastApproved;

  /// What the draft starts as for a new case. The physician edits it; nothing
  /// reaches the worker until they approve.
  static const defaultNextStep = 'A clinician will call you today to talk about your symptoms.';

  /// The starting draft in the worker's language, so an approved default
  /// never reaches a Spanish-speaking worker in English.
  static String defaultNextStepFor(Language language) => switch (language) {
    Language.en => defaultNextStep,
    Language.es => 'Un médico le llamará hoy para hablar de sus síntomas.',
  };

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
      _ => current is ReviewReady && current.intakeCase.id == c.id ? current.draft : defaultNextStepFor(c.language),
    };
    emit(ReviewState.ready(intakeCase: c, draft: draft, approving: approving));
  }

  void _onDraftChanged(NextStepDraftChanged event, Emitter<ReviewState> emit) {
    if (state case final ReviewReady ready) emit(ready.copyWith(draft: event.text, approveFailure: null));
  }

  Future<void> _onApprove(ApproveRequested event, Emitter<ReviewState> emit) async {
    final current = state;
    if (current is! ReviewReady || current.draft.trim().isEmpty) return;
    // Approving the step that's already approved changes nothing. A fast double
    // tap lands here after the first approval finished but before the case
    // update reached this Bloc, so remember what was just approved.
    final step = current.draft.trim();
    final already = switch (current.intakeCase.status) {
      Approved(:final nextStep) => nextStep == step,
      _ => false,
    };
    if (already || _lastApproved == (current.intakeCase.id, step)) return;
    emit(current.copyWith(approving: true, approveFailure: null));
    final result = await _cases.approve(current.intakeCase.id, nextStep: current.draft);
    final latest = state;
    // The page may have moved to another case meanwhile; this result isn't about it.
    if (latest is! ReviewReady || latest.intakeCase.id != current.intakeCase.id) return;
    if (result is Ok) _lastApproved = (current.intakeCase.id, step);
    emit(switch (result) {
      Ok() => latest.copyWith(approving: false),
      Err(:final failure) => latest.copyWith(approving: false, approveFailure: failure),
    });
  }
}
