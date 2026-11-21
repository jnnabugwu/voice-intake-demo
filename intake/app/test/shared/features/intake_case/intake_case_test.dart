import 'package:flutter_test/flutter_test.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/core/result.dart';
import 'package:intake/shared/features/intake_case/data/demo_summary_repository.dart';
import 'package:intake/shared/features/intake_case/data/in_memory_case_repository.dart';
import 'package:intake/shared/features/intake_case/domain/intake_case.dart';

const _case = IntakeCase(
  id: 'c_1',
  language: Language.en,
  transcript: [TranscriptLine(speaker: TranscriptSpeaker.worker, text: 'sore throat')],
);

void main() {
  group('InMemoryCaseRepository', () {
    test('watchCurrent emits null, then the submitted case, then its approval', () async {
      final repo = InMemoryCaseRepository();
      final seen = <IntakeCase?>[];
      final sub = repo.watchCurrent().listen(seen.add);
      expect(await repo.submit(_case), const Ok<void>(null));
      expect(await repo.approve('c_1', nextStep: ' Video visit today '), const Ok<void>(null));
      await pumpEventQueue();
      await sub.cancel();
      expect(seen, [null, _case, _case.copyWith(status: const CaseStatus.approved(nextStep: 'Video visit today'))]);
    });

    test('approving an unknown case or an empty step fails', () async {
      final repo = InMemoryCaseRepository();
      expect(await repo.approve('nope', nextStep: 'x'), isA<Err<void>>());
      await repo.submit(_case);
      expect(await repo.approve('c_1', nextStep: '  '), isA<Err<void>>());
    });

    test('watch(id) follows one case', () async {
      final repo = InMemoryCaseRepository();
      await repo.submit(_case);
      expect(await repo.watch('c_1').first, _case);
      expect(await repo.watch('other').first, isNull);
    });
  });

  group('DemoSummaryRepository', () {
    test('records what was said and leaves the rest null', () {
      final s = DemoSummaryRepository.summarizeText(
        'Worker: My throat has been sore for three days and it hurts to swallow.\n'
        'Assistant: How bad is it, 1 to 10?\n'
        'Worker: About a 6.\n'
        'Worker: I take ibuprofen and I am allergic to penicillin.',
        Language.en,
      );
      expect(s.chiefComplaint, 'My throat has been sore for three days and it hurts to swallow.');
      expect(s.duration, 'three days');
      expect(s.severity, 6);
      expect(s.symptoms, containsAll(['sore throat', 'pain when swallowing']));
      expect(s.medications, ['ibuprofen']);
      expect(s.allergies, ['penicillin']);
      expect(s.openQuestions, isEmpty);
    });

    test('nothing said means null and open questions, never a guess', () {
      final s = DemoSummaryRepository.summarizeText('Worker: I feel bad.', Language.en);
      expect(s.duration, isNull);
      expect(s.severity, isNull);
      expect(s.medications, isEmpty);
      expect(s.openQuestions, contains('How long has this been going on?'));
    });

    test('Spanish', () {
      final s = DemoSummaryRepository.summarizeText(
        'Worker: Me duele la garganta desde hace tres días.\nWorker: Tomo ibuprofeno. Soy alérgica a la penicilina.',
        Language.es,
      );
      expect(s.duration, 'tres días');
      expect(s.medications, ['ibuprofeno']);
      expect(s.allergies, ['penicilina']);
      expect(s.language, Language.es);
    });
  });

  group('DemoSummaryRepository never records a denial as present', () {
    test('negated symptoms, medications and allergies stay out', () {
      final s = DemoSummaryRepository.summarizeText(
        "Worker: I have a cough but no fever.\nWorker: I don't take anything, and I'm not allergic to penicillin.",
        Language.en,
      );
      expect(s.symptoms, ['cough']);
      expect(s.medications, isEmpty);
      expect(s.allergies, isEmpty);
      expect(s.openQuestions, isNot(contains('Any medications?')));
      expect(s.openQuestions, isNot(contains('Any allergies?')));
    });

    test('Spanish negation', () {
      final s = DemoSummaryRepository.summarizeText('Worker: Tengo tos, sin fiebre.', Language.es);
      expect(s.symptoms, ['cough']);
    });

    test('a denial only answers its own question', () {
      final s = DemoSummaryRepository.summarizeText('Worker: Sore throat. No allergies.', Language.en);
      expect(s.openQuestions, contains('Any medications?'));
      expect(s.openQuestions, isNot(contains('Any allergies?')));
    });

    test('a duration is not a severity; a short scale answer is', () {
      expect(DemoSummaryRepository.summarizeText('Worker: Fever for 3 days', Language.en).severity, isNull);
      expect(DemoSummaryRepository.summarizeText('Worker: about a 6', Language.en).severity, 6);
      expect(DemoSummaryRepository.summarizeText('Worker: Como un 7.', Language.es).severity, 7);
    });
  });

  group('DemoSummaryRepository lists', () {
    test('every item in a list, and an item at the end of a worker line', () {
      final s = DemoSummaryRepository.summarizeText(
        'Worker: I take aspirin and ibuprofen\nWorker: I am allergic to penicillin, sulfa\nWorker: It hurts.',
        Language.en,
      );
      expect(s.medications, ['aspirin', 'ibuprofen']);
      expect(s.allergies, ['penicillin', 'sulfa']);
    });

    test('a new clause ends the list', () {
      final s = DemoSummaryRepository.summarizeText(
        'Worker: I take ibuprofen and I am allergic to penicillin.',
        Language.en,
      );
      expect(s.medications, ['ibuprofen']);
      expect(s.allergies, ['penicillin']);
    });

    test('Spanish lists', () {
      final s = DemoSummaryRepository.summarizeText('Worker: Tomo aspirina, ibuprofeno y metformina.', Language.es);
      expect(s.medications, ['aspirina', 'ibuprofeno', 'metformina']);
    });
  });

  test('no false symptoms inside other words', () {
    final s = DemoSummaryRepository.summarizeText(
      'Worker: After the car crash my neck hurts. Mis gatos están bien.',
      Language.en,
    );
    expect(s.symptoms, isNot(contains('rash')));
    expect(s.symptoms, isNot(contains('cough')));
  });

  test('a denial on one line does not reach the next; "alérgico al"', () {
    final s = DemoSummaryRepository.summarizeText('Worker: No\nWorker: I have a cough', Language.en);
    expect(s.symptoms, ['cough']);
    final es = DemoSummaryRepository.summarizeText('Worker: Soy alérgico al ibuprofeno.', Language.es);
    expect(es.allergies, ['ibuprofeno']);
  });

  test('ordinary "I take" phrases are not medications; names with hyphens and apostrophes are kept', () {
    final s = DemoSummaryRepository.summarizeText(
      "Worker: I take the bus to work and I take care of my mom.\nWorker: I take co-codamol and st john's wort.\nWorker: I had nightmares.",
      Language.en,
    );
    expect(s.medications, ['co-codamol', "st john's wort"]);
    expect(s.symptoms, isNot(contains('dizziness')));
  });

  group('DemoSummaryRepository reads speech the way people talk', () {
    const transcript =
        'Worker: hi my name is Jordan and my stomach hurts\n'
        'Assistant: Thanks for telling me. How long has this been going on?\n'
        'Worker: this is me going on for 2 days\n'
        'Assistant: Got it, thank you. On a scale of 1 to 10, how bad is it right now?\n'
        'Worker: seven seven just just a seven\n'
        'Assistant: Got it, thank you. Is anything else bothering you, like a fever or a cough?\n'
        'Worker: no cough no fever';

    test('the answer to the 1–10 question is the severity', () {
      final s = DemoSummaryRepository.summarizeText(transcript, Language.en);
      expect(s.severity, 7);
      expect(s.duration, '2 days');
    });

    test('the complaint drops the greeting and the name; stomach pain is a symptom; denials stay out', () {
      final s = DemoSummaryRepository.summarizeText(transcript, Language.en);
      expect(s.chiefComplaint, 'My stomach hurts');
      expect(s.symptoms, ['stomach pain']);
    });

    test('Spanish: "siete" answers "del 1 al 10"', () {
      final s = DemoSummaryRepository.summarizeText(
        'Worker: Hola, me llamo Ana. Me duele el estómago.\n'
        'Assistant: Del 1 al 10, ¿qué tan fuerte es ahora?\n'
        'Worker: mmm siete',
        Language.es,
      );
      expect(s.severity, 7);
      expect(s.chiefComplaint, 'Me duele el estómago.');
      expect(s.symptoms, contains('stomach pain'));
    });

    test('an answer without a number on the scale stays unsaid', () {
      final s = DemoSummaryRepository.summarizeText(
        'Worker: my ear hurts\nAssistant: On a scale of 1 to 10, how bad is it right now?\nWorker: pretty bad',
        Language.en,
      );
      expect(s.severity, isNull);
      expect(s.symptoms, ['ear pain']);
    });
  });
}
