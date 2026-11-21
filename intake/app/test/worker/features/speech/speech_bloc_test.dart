import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intake/shared/core/failure.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/worker/features/speech/domain/speech_engine.dart';
import 'package:intake/worker/features/speech/domain/utterance.dart';
import 'package:intake/worker/features/speech/presentation/speech_bloc.dart';

import '../../../helpers/fake_speech_engine.dart';
import '../../../helpers/sequential_ids.dart';

void main() {
  late FakeSpeechEngine engine;

  setUp(() => engine = FakeSpeechEngine());

  SpeechBloc build() => SpeechBloc(engine, SequentialIds());

  blocTest<SpeechBloc, SpeechState>(
    'partials replace each other, then the final becomes the utterance',
    build: build,
    act: (bloc) async {
      bloc.add(const SpeechStarted());
      await Future<void>.delayed(Duration.zero);
      engine.emit(const SpeechResult.partial('my throat'));
      engine.emit(const SpeechResult.partial('my throat hurts'));
      await engine.end(const SpeechResult.completed('My throat hurts'));
    },
    expect: () => const [
      SpeechState(phase: SpeechPhase.starting()),
      SpeechState(phase: SpeechPhase.listening(partial: 'my throat')),
      SpeechState(phase: SpeechPhase.listening(partial: 'my throat hurts')),
      SpeechState(
        lastUtterance: Utterance(id: 'u_1', text: 'My throat hurts', language: Language.en),
      ),
    ],
    verify: (_) => expect(engine.requestedLocales, ['en-US']),
  );

  blocTest<SpeechBloc, SpeechState>(
    'Spanish listens with es-US and tags the utterance es',
    build: build,
    act: (bloc) async {
      bloc.add(const SpeechLanguageChanged(Language.es));
      bloc.add(const SpeechStarted());
      await Future<void>.delayed(Duration.zero);
      await engine.end(const SpeechResult.completed('Me duele la garganta'));
    },
    skip: 2,
    expect: () => const [
      SpeechState(
        language: Language.es,
        lastUtterance: Utterance(id: 'u_1', text: 'Me duele la garganta', language: Language.es),
      ),
    ],
    verify: (_) => expect(engine.requestedLocales, ['es-US']),
  );

  blocTest<SpeechBloc, SpeechState>(
    'stop keeps what was heard even if the engine closes without a final',
    build: build,
    act: (bloc) async {
      bloc.add(const SpeechStarted());
      await Future<void>.delayed(Duration.zero);
      engine.emit(const SpeechResult.partial('three days'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const SpeechStopped());
    },
    skip: 2,
    expect: () => const [
      SpeechState(
        lastUtterance: Utterance(id: 'u_1', text: 'three days', language: Language.en),
      ),
    ],
  );

  blocTest<SpeechBloc, SpeechState>(
    'an empty final keeps the last partial',
    build: build,
    act: (bloc) async {
      bloc.add(const SpeechStarted());
      await Future<void>.delayed(Duration.zero);
      engine.emit(const SpeechResult.partial('swollen ankles'));
      await engine.end(const SpeechResult.completed(''));
    },
    skip: 2,
    expect: () => const [
      SpeechState(
        lastUtterance: Utterance(id: 'u_1', text: 'swollen ankles', language: Language.en),
      ),
    ],
  );

  blocTest<SpeechBloc, SpeechState>(
    'a failure after partials keeps what was heard',
    build: build,
    act: (bloc) async {
      bloc.add(const SpeechStarted());
      await Future<void>.delayed(Duration.zero);
      engine.emit(const SpeechResult.partial('chest pain'));
      await engine.end(const SpeechResult.failed(NetworkFailure()));
    },
    skip: 2,
    expect: () => const [
      SpeechState(
        lastUtterance: Utterance(id: 'u_1', text: 'chest pain', language: Language.en),
        phase: SpeechPhase.unavailable(failure: NetworkFailure()),
      ),
    ],
  );

  blocTest<SpeechBloc, SpeechState>(
    'nothing heard leaves no utterance',
    build: build,
    act: (bloc) async {
      bloc.add(const SpeechStarted());
      await Future<void>.delayed(Duration.zero);
      await engine.end(const SpeechResult.completed(''));
    },
    expect: () => const [SpeechState(phase: SpeechPhase.starting()), SpeechState()],
  );

  blocTest<SpeechBloc, SpeechState>(
    'a failure moves to unavailable, and starting again recovers',
    build: build,
    act: (bloc) async {
      bloc.add(const SpeechStarted());
      await Future<void>.delayed(Duration.zero);
      await engine.end(const SpeechResult.failed(MicPermissionFailure()));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const SpeechStarted());
      await Future<void>.delayed(Duration.zero);
      await engine.end(const SpeechResult.completed('hello'));
    },
    expect: () => const [
      SpeechState(phase: SpeechPhase.starting()),
      SpeechState(phase: SpeechPhase.unavailable(failure: MicPermissionFailure())),
      SpeechState(phase: SpeechPhase.starting()),
      SpeechState(
        lastUtterance: Utterance(id: 'u_1', text: 'hello', language: Language.en),
      ),
    ],
  );

  blocTest<SpeechBloc, SpeechState>(
    'a second start while listening is dropped',
    build: build,
    act: (bloc) async {
      bloc.add(const SpeechStarted());
      bloc.add(const SpeechStarted());
      await Future<void>.delayed(Duration.zero);
      await engine.end(const SpeechResult.completed('once'));
    },
    expect: () => const [
      SpeechState(phase: SpeechPhase.starting()),
      SpeechState(
        lastUtterance: Utterance(id: 'u_1', text: 'once', language: Language.en),
      ),
    ],
    verify: (_) => expect(engine.requestedLocales, hasLength(1)),
  );

  blocTest<SpeechBloc, SpeechState>(
    'changing language mid-session stops the mic first',
    build: build,
    act: (bloc) async {
      bloc.add(const SpeechStarted());
      await Future<void>.delayed(Duration.zero);
      engine.emit(const SpeechResult.partial('hola'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const SpeechLanguageChanged(Language.es));
    },
    verify: (bloc) {
      expect(engine.stopCalls, greaterThanOrEqualTo(1));
      expect(bloc.state.language, Language.es);
    },
  );
}
