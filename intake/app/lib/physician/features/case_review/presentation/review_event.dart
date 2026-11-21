import 'package:intake/shared/features/intake_case/domain/intake_case.dart';

sealed class ReviewEvent {
  const ReviewEvent();
}

/// Open a case by ID, or the current case when [caseId] is null.
final class ReviewOpened extends ReviewEvent {
  const ReviewOpened([this.caseId]);

  final String? caseId;
}

final class NextStepDraftChanged extends ReviewEvent {
  const NextStepDraftChanged(this.text);

  final String text;
}

final class ApproveRequested extends ReviewEvent {
  const ApproveRequested();
}

/// The repository's copy of the case changed.
final class ReviewCaseUpdated extends ReviewEvent {
  const ReviewCaseUpdated(this.intakeCase);

  final IntakeCase? intakeCase;
}
