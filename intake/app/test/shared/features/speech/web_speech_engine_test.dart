import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:intake/shared/core/failure.dart';
import 'package:intake/shared/features/speech/data/web_speech_engine.dart';
import 'package:intake/shared/features/speech/domain/speech_engine.dart';
import 'package:mocktail/mocktail.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class MockSpeechToText extends Mock implements SpeechToText {}

class FakeOptions extends Fake implements SpeechListenOptions {}

void main() {
  late MockSpeechToText stt;
  SpeechErrorListener? onError;
  SpeechResultListener? onResult;
  SpeechStatusListener? onStatus;

  setUpAll(() {
    registerFallbackValue(FakeOptions());
    registerFallbackValue(Duration.zero);
  });

  setUp(() {
    stt = MockSpeechToText();
    onError = null;
    onResult = null;
    onStatus = null;
    when(() => stt.errorListener = any())
        .thenAnswer((i) => onError = i.positionalArguments.first as SpeechErrorListener?);
    when(() => stt.errorListener).thenAnswer((_) => onError);
    when(() => stt.statusListener = any())
        .thenAnswer((i) => onStatus = i.positionalArguments.first as SpeechStatusListener?);
    when(() => stt.statusListener).thenAnswer((_) => onStatus);
    when(() => stt.locales()).thenAnswer((_) async => [LocaleName('en_US', 'English')]);
    when(() => stt.cancel()).thenAnswer((_) async {});
    when(() => stt.stop()).thenAnswer((_) async {});
    when(
      () => stt.listen(
        onResult: any(named: 'onResult'),
        listenOptions: any(named: 'listenOptions'),
      ),
    ).thenAnswer((i) async => onResult = i.namedArguments[#onResult] as SpeechResultListener);
  });

  void initializeReturns(Future<bool> Function() answer) => when(
    () => stt.initialize(
      onError: any(named: 'onError'),
      onStatus: any(named: 'onStatus'),
      finalTimeout: any(named: 'finalTimeout'),
    ),
  ).thenAnswer((_) => answer());

  SpeechRecognitionResult words(String text, {bool isFinal = false}) => SpeechRecognitionResult.init([
    SpeechRecognitionWords(text, null, 0.9),
  ], isFinal ? ResultType.finalResult : ResultType.partial);

  test('a browser without speech recognition ends with SpeechUnavailableFailure', () async {
    initializeReturns(() async => false);
    final results = await WebSpeechEngine(stt).listen(localeId: 'en-US').toList();
    expect(results, [const SpeechResult.failed(SpeechUnavailableFailure())]);
  });

  test('an exception from the plugin never escapes the stream', () async {
    initializeReturns(() => Future.error(StateError('boom')));
    final results = await WebSpeechEngine(stt).listen(localeId: 'en-US').toList();
    expect(results.single, isA<SpeechFailed>());
  });

  test('partials stream, then a final result ends the session', () async {
    initializeReturns(() async => true);
    final stream = WebSpeechEngine(stt).listen(localeId: 'en-US');
    final collected = <SpeechResult>[];
    final done = stream.listen(collected.add).asFuture<void>();
    await pumpEventQueue();
    onResult!(words('chest'));
    onResult!(words('chest pain', isFinal: true));
    await done;
    expect(collected, const [SpeechResult.partial('chest'), SpeechResult.completed('chest pain')]);
  });

  test('a denied mic ends with MicPermissionFailure', () async {
    initializeReturns(() async => true);
    final stream = WebSpeechEngine(stt).listen(localeId: 'en-US');
    final future = stream.toList();
    await pumpEventQueue();
    onError!(SpeechRecognitionError('not-allowed', true));
    expect(await future, [const SpeechResult.failed(MicPermissionFailure())]);
  });

  test('no speech ends quietly with what was heard', () async {
    initializeReturns(() async => true);
    final stream = WebSpeechEngine(stt).listen(localeId: 'es-US');
    final future = stream.toList();
    await pumpEventQueue();
    onResult!(words('hola'));
    onError!(SpeechRecognitionError('no-speech', false));
    expect(await future, const [SpeechResult.partial('hola'), SpeechResult.completed('hola')]);
  });

  test('done from the plugin ends the session with what was heard', () async {
    initializeReturns(() async => true);
    final future = WebSpeechEngine(stt).listen(localeId: 'en-US').toList();
    await pumpEventQueue();
    onResult!(words('three days'));
    onStatus!(SpeechToText.doneStatus);
    expect(await future, const [SpeechResult.partial('three days'), SpeechResult.completed('three days')]);
  });

  test('when Chrome stops by itself and no final comes, the fallback ends the session', () async {
    initializeReturns(() async => true);
    final future = WebSpeechEngine(stt).listen(localeId: 'en-US').toList();
    await pumpEventQueue();
    onResult!(words('a fever'));
    onStatus!(SpeechToText.notListeningStatus);
    final results = await future.timeout(WebSpeechEngine.fallback * 2);
    expect(results.last, const SpeechResult.completed('a fever'));
  });

  test('stop while the mic is still starting never opens it', () async {
    final init = Completer<bool>();
    initializeReturns(() => init.future);
    final engine = WebSpeechEngine(stt);
    final future = engine.listen(localeId: 'en-US').toList();
    await pumpEventQueue();
    await engine.stop();
    init.complete(true);
    expect(await future, const [SpeechResult.completed('')]);
    verifyNever(
      () => stt.listen(
        onResult: any(named: 'onResult'),
        listenOptions: any(named: 'listenOptions'),
      ),
    );
  });

  test("a new session ends the older one with the older one's words", () async {
    initializeReturns(() async => true);
    final engine = WebSpeechEngine(stt);
    final first = engine.listen(localeId: 'en-US').toList();
    await pumpEventQueue();
    onResult!(words('hello'));
    final second = engine.listen(localeId: 'es-US').listen((_) {});
    expect(await first, const [SpeechResult.partial('hello'), SpeechResult.completed('hello')]);
    await pumpEventQueue();
    verify(() => stt.cancel()).called(1); // the old recognizer stopped before the new one started
    await second.cancel();
  });
}
