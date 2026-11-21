import 'package:intake/shared/core/result.dart';
import 'package:intake/shared/features/intake_case/domain/intake_case.dart';
import 'package:meta/meta.dart';

/// The one copy of each case, and the only channel between the sides: the
/// worker side submits, the physician side approves, both watch.
abstract interface class CaseRepository {
  /// The case most recently submitted, or null. Emits the current value first.
  Stream<IntakeCase?> watchCurrent();

  /// One case by ID, or null if there is none. Emits the current value first.
  Stream<IntakeCase?> watch(String caseId);

  @useResult
  Future<Result<void>> submit(IntakeCase intakeCase);

  @useResult
  Future<Result<void>> approve(String caseId, {required String nextStep});
}
