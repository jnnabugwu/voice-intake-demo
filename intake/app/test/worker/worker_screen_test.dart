import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intake/shared/core/failure.dart';
import 'package:intake/worker/features/speech/domain/speech_engine.dart';

import '../helpers/fake_speech_engine.dart';
import '../helpers/pump_app.dart';

void main() {
  testWidgets('live partial words show while speaking, and the final stays', (tester) async {
    final engine = FakeSpeechEngine();
    await pumpApp(tester, speech: engine);

    await tester.tap(find.bySemanticsLabel('Start listening'));
    await tester.pump();
    engine.emit(const SpeechResult.partial('my ankles are'));
    await tester.pump();
    expect(find.text('my ankles are'), findsOneWidget);
    expect(find.bySemanticsLabel('Listening, tap to stop'), findsOneWidget);

    await engine.end(const SpeechResult.completed('my ankles are swollen'));
    await tester.pumpAndSettle();
    expect(find.text('my ankles are swollen'), findsOneWidget);
    expect(find.bySemanticsLabel('Start listening'), findsOneWidget);
  });

  testWidgets('without speech recognition the screen explains why and offers typing', (tester) async {
    final engine = FakeSpeechEngine();
    await pumpApp(tester, speech: engine);

    await tester.tap(find.bySemanticsLabel('Start listening'));
    await tester.pump();
    await engine.end(const SpeechResult.failed(SpeechUnavailableFailure()));
    await tester.pumpAndSettle();

    expect(find.text("This browser doesn't support speech recognition"), findsOneWidget);
    expect(find.textContaining('Works best in Chrome'), findsOneWidget);
    expect(find.byType(EditableText), findsOneWidget);
  });

  testWidgets('ES switches the worker side to Spanish', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('ES'));
    await tester.pumpAndSettle();
    expect(find.text('Toque el micrófono y hable'), findsOneWidget);
    expect(find.bySemanticsLabel('Empezar a escuchar'), findsOneWidget);
  });
}
