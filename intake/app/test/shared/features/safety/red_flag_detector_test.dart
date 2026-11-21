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

  test('common wordings', () {
    expect(detector.detect('Me quiero matar')!.kind, RedFlagKind.crisis);
    for (final t in [
      'I have shortness of breath',
      'Tengo dolor de pecho',
      "I think it's a heart attack",
      'Creo que es un ataque al corazón',
      'Mi papá tuvo un infarto',
    ]) {
      expect(detector.detect(t)?.kind, RedFlagKind.emergency, reason: t);
    }
  });

  test('Spanish matches with or without accents, and with possessives', () {
    for (final t in ['No quiero estar aqui', 'no quiero estar aquí', 'Quiero hacerme dano']) {
      expect(detector.detect(t)?.kind, RedFlagKind.crisis, reason: t);
    }
    for (final t in [
      'Tengo dolor en mi pecho',
      'me duele mi pecho',
      'siento presion en el pecho',
      'Siento presión en mi pecho',
      'No puedo mover mi brazo',
      'no puedo mover la pierna',
      'tengo la cara caida',
      'Está muy confundido',
    ]) {
      expect(detector.detect(t)?.kind, RedFlagKind.emergency, reason: t);
    }
  });

  test('a denial is not a red flag; an affirmed one in the same message still is', () {
    for (final t in [
      'I have no chest pain',
      "I don't have chest pain, just a cough",
      'Sin dolor de pecho',
      'No tengo dolor en el pecho',
      "I'm not short of breath",
    ]) {
      expect(detector.detect(t), isNull, reason: t);
    }
    expect(detector.detect("No chest pain, but I can't breathe")?.kind, RedFlagKind.emergency);
    expect(detector.detect("I have no fever and can't breathe")?.kind, RedFlagKind.emergency);
    expect(detector.detect('No tengo fiebre y me falta el aire')?.kind, RedFlagKind.emergency);
  });

  test('lay stroke wordings', () {
    for (final t in ["My face is drooping and I'm slurring", 'numbness in my arm', 'tengo el brazo entumecido']) {
      expect(detector.detect(t)?.kind, RedFlagKind.emergency, reason: t);
    }
  });

  test('overdose is a crisis; an accidental injury is not', () {
    for (final t in [
      'I took a whole bottle of pills',
      'I think I overdosed',
      'Me tomé todas las pastillas',
      'sobredosis',
    ]) {
      expect(detector.detect(t)?.kind, RedFlagKind.crisis, reason: t);
    }
    expect(detector.detect('I hurt myself lifting boxes at work'), isNull);
    expect(detector.detect('I want to hurt myself')?.kind, RedFlagKind.crisis);
  });

  test('single stroke signs, chest pressure, and uncontracted crisis wording', () {
    for (final t in [
      'I have chest pressure',
      'pain in chest',
      'my face is drooping',
      'facial droop',
      'my arm is numb',
    ]) {
      expect(detector.detect(t)?.kind, RedFlagKind.emergency, reason: t);
    }
    for (final t in ['I do not want to live', 'I do not want to be alive']) {
      expect(detector.detect(t)?.kind, RedFlagKind.crisis, reason: t);
    }
  });
}
