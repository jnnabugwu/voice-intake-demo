import 'package:intake/shared/core/failure.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/core/result.dart';
import 'package:intake/shared/features/intake_case/data/demo_summary_repository.dart';
import 'package:intake/shared/features/intake_case/data/in_memory_case_repository.dart';
import 'package:intake/shared/features/intake_case/domain/intake_case.dart';
import 'package:intake/shared/features/intake_case/domain/intake_summary.dart';
import 'package:intake/shared/features/intake_case/domain/summary_repository.dart';
import 'package:intake/shared/features/safety/domain/red_flag.dart';
import 'package:intake/worker/features/conversation/domain/chat_chunk.dart';
import 'package:intake/worker/features/conversation/domain/submit_intake.dart';
import 'package:intake/worker/features/conversation/domain/turn.dart';
import 'package:intake/worker/features/conversation/presentation/conversation_bloc.dart';

import '../../../helpers/fake_chat_repository.dart';
import '../../../helpers/sequential_ids.dart';

class _FlaggingSummaries implements SummaryRepository {
  _FlaggingSummaries(this.flags);

  final List<String> flags;

  @override
  Future<Result<IntakeSummary>> summarize({
    required String conversationId,
    required Language language,
    required String transcript,
  }) async => Ok(IntakeSummary(language: language, transcript: transcript, redFlags: flags));
}

void main() {
  test('a red flag stops the chat before any model call and escalates the case', () async {
    final chat = FakeChatRepository([]);
    final cases = InMemoryCaseRepository();
    final bloc = ConversationBloc(chat, SequentialIds(), SubmitIntake(const DemoSummaryRepository(), cases));
    bloc.add(
      const TypedMessageSubmitted(
        text: 'Tengo un dolor en el pecho que me baja por el brazo izquierdo, y me falta el aire.',
        language: Language.es,
      ),
    );
    await pumpEventQueue();
    expect(chat.calls, isEmpty);
    expect(bloc.state.phase, isA<RedFlagRaised>());
    final submitted = await cases.watchCurrent().first;
    expect(submitted!.redFlag?.kind, RedFlagKind.emergency);
    expect(submitted.status, const CaseStatus.awaitingReview());
    await bloc.close();
  });

  test('approving an escalated case keeps the escalation record', () async {
    final cases = InMemoryCaseRepository();
    const flag = RedFlag(kind: RedFlagKind.crisis, reason: 'no quiero vivir');
    final _ = await cases.submit(const IntakeCase(id: 'c_1', language: Language.es, transcript: [], redFlag: flag));
    final approved = await cases.approve('c_1', nextStep: 'A clinician will call you now.');
    expect(approved, const Ok<void>(null));
    final c = (await cases.watchCurrent().first)!;
    expect(c.status, const CaseStatus.approved(nextStep: 'A clinician will call you now.'));
    expect(c.redFlag, flag);
  });

  test('chunks after a red_flag event are ignored', () async {
    final cases = InMemoryCaseRepository();
    final bloc = ConversationBloc(
      FakeChatRepository([
        [const ChatChunk.redFlag(RedFlagKind.emergency), const ChatChunk.delta('late'), const ChatChunk.done()],
      ]),
      SequentialIds(),
      SubmitIntake(const DemoSummaryRepository(), cases),
    );
    bloc.add(const TypedMessageSubmitted(text: 'something the app missed', language: Language.en));
    await pumpEventQueue();
    expect(bloc.state.phase, isA<RedFlagRaised>());
    expect(bloc.state.turns.where((t) => t.speaker == Speaker.assistant), isEmpty);
    expect((await cases.watchCurrent().first)!.redFlag?.kind, RedFlagKind.emergency);
    await bloc.close();
  });

  test("the proxy's red_flag event escalates too", () async {
    final cases = InMemoryCaseRepository();
    final bloc = ConversationBloc(
      FakeChatRepository([
        [const ChatChunk.redFlag(RedFlagKind.crisis)],
      ]),
      SequentialIds(),
      SubmitIntake(const DemoSummaryRepository(), cases),
    );
    bloc.add(const TypedMessageSubmitted(text: 'something the app missed', language: Language.en));
    await pumpEventQueue();
    expect(bloc.state.phase, isA<RedFlagRaised>());
    expect((await cases.watchCurrent().first)!.redFlag?.kind, RedFlagKind.crisis);
    await bloc.close();
  });

  test('a refusal offers the clinician and the help lines, without stopping the chat', () async {
    final bloc = ConversationBloc(
      FakeChatRepository([
        [const ChatChunk.refused()],
      ]),
      SequentialIds(),
      SubmitIntake(const DemoSummaryRepository(), InMemoryCaseRepository()),
    );
    bloc.add(const TypedMessageSubmitted(text: 'what dose should I take', language: Language.en));
    await pumpEventQueue();
    expect(bloc.state.clinicianOffered, isTrue);
    expect(bloc.state.phase, const ConversationPhase.gathering());
    await bloc.close();
  });

  for (final (flags, kind) in [
    (['sudden weakness on one side'], RedFlagKind.emergency),
    (['passive suicidal ideation'], RedFlagKind.crisis),
  ]) {
    test('a red flag in the summary escalates the case (${kind.name})', () async {
      final cases = InMemoryCaseRepository();
      final result = await SubmitIntake(_FlaggingSummaries(flags), cases)(
        conversationId: 'c_1',
        language: Language.en,
        turns: const [Turn(id: 'u', speaker: Speaker.worker, text: 'my arm feels weird', language: Language.en)],
      );
      expect(result, const Ok<void>(null));
      expect((await cases.watchCurrent().first)!.redFlag, RedFlag(kind: kind, reason: flags.first));
    });
  }

  test('a failed escalation submit is retried until the physician has the case', () {
    fakeAsync((async) {
      final cases = _FailingTwice();
      final bloc = ConversationBloc(
        FakeChatRepository([]),
        SequentialIds(),
        SubmitIntake(const DemoSummaryRepository(), cases),
      );
      bloc.add(const TypedMessageSubmitted(text: 'I have chest pain', language: Language.en));
      async.elapse(const Duration(seconds: 10));
      expect(cases.attempts, 3);
      expect(cases.stored, isNotNull);
      bloc.close();
      async.flushMicrotasks();
    });
  });
}

class _FailingTwice extends InMemoryCaseRepository {
  int attempts = 0;
  IntakeCase? stored;

  @override
  Future<Result<void>> submit(IntakeCase intakeCase) async {
    attempts++;
    if (attempts <= 2) return const Err(NetworkFailure());
    stored = intakeCase;
    return super.submit(intakeCase);
  }
}
