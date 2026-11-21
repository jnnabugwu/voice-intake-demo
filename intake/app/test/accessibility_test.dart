import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/features/intake_case/data/in_memory_case_repository.dart';
import 'package:intake/shared/features/intake_case/domain/intake_case.dart';
import 'package:intake/shared/features/intake_case/domain/intake_summary.dart';

import 'helpers/pump_app.dart';

/// ARCHITECTURE.md § Accessibility: tap targets, labels and contrast on
/// every screen, light and dark, English and Spanish.
Future<void> meetsAllGuidelines(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

void main() {
  for (final dark in [false, true]) {
    for (final language in Language.values) {
      final label = '${dark ? 'dark' : 'light'} ${language.code}';

      testWidgets('worker screen, $label', (tester) async {
        final semantics = tester.ensureSemantics();
        tester.platformDispatcher.platformBrightnessTestValue = dark ? Brightness.dark : Brightness.light;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        await pumpApp(tester);
        if (language == Language.es) {
          await tester.tap(find.text('ES'));
          await tester.pumpAndSettle();
        }
        await tester.enterText(find.byType(EditableText), 'Me duele la garganta');
        await tester.testTextInput.receiveAction(TextInputAction.send);
        await tester.pumpAndSettle();
        await meetsAllGuidelines(tester);
        semantics.dispose();
      });

      testWidgets('physician screen, $label', (tester) async {
        final semantics = tester.ensureSemantics();
        tester.platformDispatcher.platformBrightnessTestValue = dark ? Brightness.dark : Brightness.light;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        final cases = InMemoryCaseRepository();
        final _ = await cases.submit(
          IntakeCase(
            id: 'c_1',
            language: language,
            transcript: const [TranscriptLine(speaker: TranscriptSpeaker.worker, text: 'sore throat')],
            summary: IntakeSummary(
              chiefComplaint: 'Sore throat',
              severity: 6,
              symptoms: const ['sore throat'],
              language: language,
              openQuestions: const ['Any fever?'],
              transcript: 'Worker: sore throat',
            ),
          ),
        );
        await pumpApp(tester, location: '/physician', cases: cases);
        await meetsAllGuidelines(tester);
        semantics.dispose();
      });
    }
  }
}
