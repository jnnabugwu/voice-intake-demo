import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intake/shared/core/failure.dart';
import 'package:intake/shared/features/intake_case/domain/intake_case.dart';

part 'review_state.freezed.dart';

@freezed
sealed class ReviewState with _$ReviewState {
  const factory ReviewState.loading() = ReviewLoading;
  const factory ReviewState.noCase() = ReviewNoCase;

  /// [draft] is the next step as the physician is writing it.
  const factory ReviewState.ready({
    required IntakeCase intakeCase,
    required String draft,
    @Default(false) bool approving,
    Failure? approveFailure,
  }) = ReviewReady;
}
