import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/features/safety/domain/red_flag.dart';
import 'package:intake/shared/features/safety/domain/red_flag_detector.dart';

void main() {
  // The bench script is the source of truth for which lines must escalate.
  final refs = jsonDecode(File('../../bench/references.json').readAsStringSync()) as Map<String, dynamic>;
  final lines = (refs['lines'] as List).cast<Map<String, dynamic>>();
  const detector = RedFlagDetector();

  group('every bench line, both languages', () {
    for (final line in lines) {
      for (final lang in Language.values) {
        final text = (line[lang.code] as Map<String, dynamic>)['text'] as String;
        final expected = line['expect_red_flag'] as bool;
        test('line ${line['n']} ${lang.code} ${expected ? 'escalates' : 'does not escalate'}', () {
          expect(detector.detect(text, language: lang) != null, expected);
        });
      }
    }
  });

  test('crisis language is told apart from an emergency', () {
    expect(detector.detect("I don't want to be here anymore")!.kind, RedFlagKind.crisis);
    expect(detector.detect('Ya no quiero vivir')!.kind, RedFlagKind.crisis);
    expect(detector.detect('My chest hurts')!.kind, RedFlagKind.emergency);
  });
}
