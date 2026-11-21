import 'package:flutter_test/flutter_test.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/features/intake_case/data/in_memory_case_repository.dart';
import 'package:intake/shared/features/intake_case/domain/intake_case.dart';
import 'package:intake/worker/features/next_step/presentation/next_step_bloc.dart';

void main() {
  test('none, locked once submitted, unlocked only by approval', () async {
    final repo = InMemoryCaseRepository();
    final bloc = NextStepBloc(repo)..add(const NextStepWatchStarted());
    final states = <NextStepState>[];
    final sub = bloc.stream.listen(states.add);
    await pumpEventQueue();
    await repo.submit(const IntakeCase(id: 'c_1', language: Language.en, transcript: []));
    await pumpEventQueue();
    await repo.approve('c_1', nextStep: 'Video visit today');
    await pumpEventQueue();
    await sub.cancel();
    expect(states, const [
      NextStepState.none(),
      NextStepState.locked(),
      NextStepState.unlocked(nextStep: 'Video visit today'),
    ]);
    await bloc.close();
  });
}
