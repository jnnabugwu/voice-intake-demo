import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intake/shared/core/failure.dart';
import 'package:intake/worker/features/speech/domain/speech_engine.dart';

import 'package:intake/worker/features/conversation/data/demo_chat_repository.dart';

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

  testWidgets('demo mode runs a full typed intake with no keys', (tester) async {
    await pumpApp(tester);
    Future<void> say(String text) async {
      await tester.enterText(find.byType(EditableText), text);
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pumpAndSettle();
    }

    await say('My throat has been sore for three days and it hurts to swallow');
    expect(find.textContaining('how bad is it'), findsOneWidget);
    await say('About a 6 out of 10');
    await say('No, nothing else');
    await say('I take ibuprofen and I am allergic to penicillin');
    expect(find.textContaining('Tap Finish'), findsOneWidget);

    await tester.ensureVisible(find.text('Finish'));
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(find.text('Done. A clinician is reviewing what you shared.'), findsOneWidget);
    expect(find.byType(EditableText), findsNothing);
  });

  testWidgets('speech that finishes while a reply streams is sent once the reply ends', (tester) async {
    final engine = FakeSpeechEngine();
    await pumpApp(
      tester,
      speech: engine,
      chat: DemoChatRepository(wordDelay: const Duration(milliseconds: 20)),
    );

    await tester.tap(find.bySemanticsLabel('Start listening'));
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'My throat hurts');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump(const Duration(milliseconds: 30)); // reply is streaming
    await engine.end(const SpeechResult.completed('for three days'));
    await tester.pump(const Duration(seconds: 5)); // let both demo replies stream out
    await tester.pumpAndSettle();
    expect(find.text('for three days'), findsOneWidget);
    expect(find.textContaining('how bad is it'), findsOneWidget);
  });

  testWidgets('Finish is disabled while the mic is live', (tester) async {
    final engine = FakeSpeechEngine();
    await pumpApp(tester, speech: engine);
    await tester.enterText(find.byType(EditableText), 'My throat hurts');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Start listening'));
    await tester.pump();
    engine.emit(const SpeechResult.partial('and'));
    await tester.pump();
    await tester.tap(find.text('Finish'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 100)); // the live mic pulses, so it never settles
    expect(find.text('Done. A clinician is reviewing what you shared.'), findsNothing);
  });

  testWidgets('approval gate: the next step stays locked until the physician approves', (tester) async {
    await pumpApp(tester);
    await tester.enterText(find.byType(EditableText), 'My throat has been sore for three days');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Finish'));
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Waiting for a clinician'), findsOneWidget);
    expect(find.textContaining('Video visit'), findsNothing);

    // Physician side: the case is there with its summary; edit the step and approve.
    await tester.tap(find.text('Physician'));
    await tester.pumpAndSettle();
    expect(find.text('My throat has been sore for three days'), findsWidgets);
    await tester.enterText(find.byType(EditableText), 'Video visit at 3 pm today.');
    await tester.pump();

    // A draft is not an approval: the worker is still locked.
    await tester.tap(find.text('Worker'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Waiting for a clinician'), findsOneWidget);
    expect(find.textContaining('Video visit'), findsNothing);
    await tester.tap(find.text('Physician'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Approve'));
    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();

    // Worker side: unlocked, showing exactly what the physician approved.
    await tester.tap(find.text('Worker'));
    await tester.pumpAndSettle();
    expect(find.text('Approved by a clinician'), findsOneWidget);
    expect(find.text('Video visit at 3 pm today.'), findsOneWidget);
    expect(find.textContaining('Waiting for a clinician'), findsNothing);
  });
}
