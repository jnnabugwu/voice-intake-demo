import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intake/shared/features/intake_case/domain/case_repository.dart';
import 'package:intake/shared/features/intake_case/domain/intake_case.dart';
import 'package:intake/shared/features/safety/domain/red_flag.dart';

part 'next_step_bloc.freezed.dart';

@freezed
sealed class NextStepState with _$NextStepState {
  /// No case submitted yet; nothing to show.
  const factory NextStepState.none() = NextStepNone;

  /// Submitted, waiting for a clinician. No content.
  const factory NextStepState.locked() = NextStepLocked;
  const factory NextStepState.unlocked({required String nextStep}) = NextStepUnlocked;

  /// The case escalated (for example, a red flag in the summary): show 911 / 988.
  const factory NextStepState.escalated({required RedFlag flag}) = NextStepEscalated;
}

sealed class NextStepEvent {
  const NextStepEvent();
}

final class NextStepWatchStarted extends NextStepEvent {
  const NextStepWatchStarted();
}

/// The worker's next step: locked until a clinician approves. It only
/// watches; the repository holds the one copy of "is this approved?".
class NextStepBloc extends Bloc<NextStepEvent, NextStepState> {
  NextStepBloc(this._cases) : super(const NextStepState.none()) {
    on<NextStepWatchStarted>(
      (event, emit) => emit.forEach<IntakeCase?>(
        _cases.watchCurrent(),
        onData: (c) => switch (c?.status) {
          null => const NextStepState.none(),
          AwaitingReview() => const NextStepState.locked(),
          Approved(:final nextStep) => NextStepState.unlocked(nextStep: nextStep),
          Escalated(:final flag) => NextStepState.escalated(flag: flag),
        },
      ),
    );
  }

  final CaseRepository _cases;
}
