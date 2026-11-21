import 'dart:async';

import 'package:intake/shared/core/failure.dart';
import 'package:intake/shared/core/result.dart';
import 'package:intake/shared/features/intake_case/domain/case_repository.dart';
import 'package:intake/shared/features/intake_case/domain/intake_case.dart';

/// Both sides read this one store in the demo, so an approval on one side
/// unlocks the next step on the other at once. Production swaps in the
/// backend's live case feed behind the same interface.
class InMemoryCaseRepository implements CaseRepository {
  final _cases = <String, IntakeCase>{};
  String? _currentId;
  final _changes = StreamController<void>.broadcast(sync: true);

  IntakeCase? get _current => _currentId == null ? null : _cases[_currentId];

  Stream<T> _watch<T>(T Function() read) => Stream<T>.multi((controller) {
    controller.add(read());
    final sub = _changes.stream.listen((_) => controller.add(read()));
    controller.onCancel = sub.cancel;
  });

  @override
  Stream<IntakeCase?> watchCurrent() => _watch(() => _current).distinct();

  @override
  Stream<IntakeCase?> watch(String caseId) => _watch(() => _cases[caseId]).distinct();

  @override
  Future<Result<void>> submit(IntakeCase intakeCase) async {
    _cases[intakeCase.id] = intakeCase;
    _currentId = intakeCase.id;
    _changes.add(null);
    return const Ok(null);
  }

  @override
  Future<Result<void>> approve(String caseId, {required String nextStep}) async {
    final existing = _cases[caseId];
    final step = nextStep.trim();
    if (existing == null || step.isEmpty) return const Err(UnknownFailure('no_case_or_empty_step'));
    _cases[caseId] = existing.copyWith(status: CaseStatus.approved(nextStep: step));
    _changes.add(null);
    return const Ok(null);
  }
}
