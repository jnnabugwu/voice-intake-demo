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
  @override
  Future<Result<IntakeSummary>> summarize({
    required String conversationId,
    required Language language,
    required String transcript,
  }) async =>
      Ok(IntakeSummary(language: language, transcript: transcript, redFlags: const ['sudden weakness on one side']));
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
    expect(submitted!.status, isA<Escalated>());
    expect((submitted.status as Escalated).flag.kind, RedFlagKind.emergency);
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
    expect((await cases.watchCurrent().first)!.status, isA<Escalated>());
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

  test('a red flag in the summary escalates the case', () async {
    final cases = InMemoryCaseRepository();
    final result = await SubmitIntake(_FlaggingSummaries(), cases)(
      conversationId: 'c_1',
      language: Language.en,
      turns: const [Turn(id: 'u', speaker: Speaker.worker, text: 'my arm feels weird', language: Language.en)],
    );
    expect(result, const Ok<void>(null));
    final status = (await cases.watchCurrent().first)!.status;
    expect(
      status,
      const CaseStatus.escalated(
        flag: RedFlag(kind: RedFlagKind.emergency, reason: 'sudden weakness on one side'),
      ),
    );
  });
}
