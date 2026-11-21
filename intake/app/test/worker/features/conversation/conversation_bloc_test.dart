import 'package:intake/shared/features/intake_case/domain/intake_case.dart';
import 'package:intake/shared/core/result.dart';
import 'package:intake/shared/core/failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/worker/features/conversation/domain/chat_chunk.dart';
import 'package:intake/worker/features/conversation/domain/turn.dart';
import 'package:intake/worker/features/conversation/presentation/conversation_bloc.dart';

import 'package:intake/shared/features/intake_case/data/demo_summary_repository.dart';
import 'package:intake/shared/features/intake_case/data/in_memory_case_repository.dart';
import 'package:intake/worker/features/conversation/domain/submit_intake.dart';

import '../../../helpers/fake_chat_repository.dart';
import '../../../helpers/sequential_ids.dart';

class _FlakyCases extends InMemoryCaseRepository {
  int attempts = 0;

  @override
  Future<Result<void>> submit(IntakeCase intakeCase) async {
    attempts++;
    return attempts == 1 ? const Err(NetworkFailure()) : super.submit(intakeCase);
  }
}

SubmitIntake submit() => SubmitIntake(const DemoSummaryRepository(), InMemoryCaseRepository());

void main() {
  const worker = Turn(id: 'u_9', speaker: Speaker.worker, text: 'My throat hurts', language: Language.en);

  test('a reply streams into the streaming phase, then lands as a turn', () async {
    final bloc = ConversationBloc(
      FakeChatRepository([
        [const ChatChunk.delta('How'), const ChatChunk.delta(' long?'), const ChatChunk.done()],
      ]),
      SequentialIds(),
      submit(),
    );
    final states = <ConversationState>[];
    final sub = bloc.stream.listen(states.add);
    bloc.add(const UtteranceSubmitted(utteranceId: 'u_9', text: 'My throat hurts ', language: Language.en));
    await pumpEventQueue();
    await sub.cancel();
    await bloc.close();
    expect(states, const [
      ConversationState(conversationId: 'c_1', turns: [worker]),
      ConversationState(
        conversationId: 'c_1',
        turns: [worker],
        phase: ConversationPhase.streaming(turnId: 't_2', reply: ''),
      ),
      ConversationState(
        conversationId: 'c_1',
        turns: [worker],
        phase: ConversationPhase.streaming(turnId: 't_2', reply: 'How'),
      ),
      ConversationState(
        conversationId: 'c_1',
        turns: [worker],
        phase: ConversationPhase.streaming(turnId: 't_2', reply: 'How long?'),
      ),
      ConversationState(
        conversationId: 'c_1',
        turns: [
          worker,
          Turn(id: 't_2', speaker: Speaker.assistant, text: 'How long?', language: Language.en),
        ],
      ),
    ]);
  });

  test('a failed reply ends the stream, and a retry reuses the turn ID and recovers', () async {
    final chat = FakeChatRepository([
      [const ChatChunk.delta('Ho'), const ChatChunk.failed(NetworkFailure())],
      [const ChatChunk.delta('How long?'), const ChatChunk.done()],
    ]);
    final bloc = ConversationBloc(chat, SequentialIds(), submit());
    bloc.add(const TypedMessageSubmitted(text: 'sore throat', language: Language.en));
    await pumpEventQueue();
    expect(bloc.state.phase, const ConversationPhase.replyFailed(turnId: 't_3', failure: NetworkFailure()));

    bloc.add(const ReplyRetryRequested());
    await pumpEventQueue();
    expect(chat.calls.map((c) => c.turnId), ['t_3', 't_3']);
    expect(bloc.state.phase, const ConversationPhase.gathering());
    expect(bloc.state.turns.last.text, 'How long?');
    expect(bloc.state.turns, hasLength(2));
    await bloc.close();
  });

  test('a second message while a reply streams is ignored', () async {
    final chat = FakeChatRepository([
      [const ChatChunk.delta('One'), const ChatChunk.done()],
    ]);
    final bloc = ConversationBloc(chat, SequentialIds(), submit());
    bloc.add(const TypedMessageSubmitted(text: 'first', language: Language.en));
    await Future<void>.delayed(Duration.zero);
    bloc.add(const TypedMessageSubmitted(text: 'second', language: Language.en));
    await pumpEventQueue();
    expect(chat.calls, hasLength(1));
    expect(bloc.state.turns.map((t) => t.text), ['first', 'One']);
    await bloc.close();
  });

  test('the same utterance handed off twice is answered once', () async {
    final chat = FakeChatRepository([
      [const ChatChunk.done()],
      [const ChatChunk.done()],
    ]);
    final bloc = ConversationBloc(chat, SequentialIds(), submit());
    const event = UtteranceSubmitted(utteranceId: 'u_1', text: 'hi', language: Language.en);
    bloc.add(event);
    await pumpEventQueue();
    bloc.add(event);
    await pumpEventQueue();
    expect(chat.calls, hasLength(1));
    await bloc.close();
  });

  test('a refusal becomes the clinician message in the worker language', () async {
    final bloc = ConversationBloc(
      FakeChatRepository([
        [const ChatChunk.refused()],
      ]),
      SequentialIds(),
      submit(),
    );
    bloc.add(const TypedMessageSubmitted(text: '¿Qué dosis tomo?', language: Language.es));
    await pumpEventQueue();
    expect(bloc.state.turns.last.text, 'Déjeme conectarlo con un médico.');
    await bloc.close();
  });

  test('Finish needs at least one message and ends gathering', () async {
    final bloc = ConversationBloc(
      FakeChatRepository([
        [const ChatChunk.done()],
      ]),
      SequentialIds(),
      submit(),
    );
    bloc.add(const FinishRequested());
    await pumpEventQueue();
    expect(bloc.state.phase, const ConversationPhase.gathering());
    bloc.add(const TypedMessageSubmitted(text: 'hi', language: Language.en));
    await pumpEventQueue();
    bloc.add(const FinishRequested());
    await pumpEventQueue();
    expect(bloc.state.phase, const ConversationPhase.finished());
    await bloc.close();
  });

  test('a second retry tap while retrying is ignored and the retry completes', () async {
    final chat = FakeChatRepository([
      [const ChatChunk.failed(NetworkFailure())],
      [const ChatChunk.delta('How long?'), const ChatChunk.done()],
      [const ChatChunk.done()],
    ]);
    final bloc = ConversationBloc(chat, SequentialIds(), submit());
    bloc.add(const TypedMessageSubmitted(text: 'sore throat', language: Language.en));
    await pumpEventQueue();
    bloc
      ..add(const ReplyRetryRequested())
      ..add(const ReplyRetryRequested());
    await pumpEventQueue();
    expect(chat.calls, hasLength(2));
    expect(bloc.state.phase, const ConversationPhase.gathering());
    expect(bloc.state.turns.last.text, 'How long?');
    await bloc.close();
  });

  test('a reply stream that closes without done is a retryable failure', () async {
    final chat = FakeChatRepository([
      [const ChatChunk.delta('How lo')],
      [const ChatChunk.delta('How long?'), const ChatChunk.done()],
    ]);
    final bloc = ConversationBloc(chat, SequentialIds(), submit());
    bloc.add(const TypedMessageSubmitted(text: 'sore throat', language: Language.en));
    await pumpEventQueue();
    expect(bloc.state.phase, isA<ReplyFailed>());
    expect(bloc.state.turns, hasLength(1));
    bloc.add(const ReplyRetryRequested());
    await pumpEventQueue();
    expect(bloc.state.turns.last.text, 'How long?');
    await bloc.close();
  });

  test('a failed submit surfaces, and Finish again retries it', () async {
    final cases = _FlakyCases();
    final bloc = ConversationBloc(
      FakeChatRepository([
        [const ChatChunk.done()],
      ]),
      SequentialIds(),
      SubmitIntake(const DemoSummaryRepository(), cases),
    );
    bloc.add(const TypedMessageSubmitted(text: 'hi', language: Language.en));
    await pumpEventQueue();
    bloc.add(const FinishRequested());
    await pumpEventQueue();
    expect(bloc.state.phase, const ConversationPhase.submitFailed(failure: NetworkFailure()));
    bloc.add(const FinishRequested());
    await pumpEventQueue();
    expect(bloc.state.phase, const ConversationPhase.finished());
    expect(cases.attempts, 2);
    await bloc.close();
  });

  test('Finish works after a failed reply, so the worker is never trapped', () async {
    final bloc = ConversationBloc(
      FakeChatRepository([
        [const ChatChunk.failed(NetworkFailure())],
      ]),
      SequentialIds(),
      submit(),
    );
    bloc.add(const TypedMessageSubmitted(text: 'sore throat', language: Language.en));
    await pumpEventQueue();
    expect(bloc.state.phase, isA<ReplyFailed>());
    bloc.add(const FinishRequested());
    await pumpEventQueue();
    expect(bloc.state.phase, const ConversationPhase.finished());
    await bloc.close();
  });
}
