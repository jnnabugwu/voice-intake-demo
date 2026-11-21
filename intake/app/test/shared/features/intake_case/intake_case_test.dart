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
}
