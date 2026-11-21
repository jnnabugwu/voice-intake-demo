import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intake/shared/core/ids.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/worker/features/conversation/domain/chat_chunk.dart';
import 'package:intake/worker/features/conversation/domain/chat_repository.dart';
import 'package:intake/worker/features/conversation/domain/turn.dart';
import 'package:intake/worker/features/conversation/presentation/conversation_event.dart';
import 'package:intake/worker/features/conversation/presentation/conversation_state.dart';
import 'package:intake/worker/features/conversation/presentation/conversation_strings.dart';

export 'package:intake/worker/features/conversation/presentation/conversation_event.dart';
export 'package:intake/worker/features/conversation/presentation/conversation_state.dart';

/// Owns the conversation: the turns, the streaming reply, and finishing the intake.
class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  ConversationBloc(this._chat, this._ids) : super(ConversationState(conversationId: _ids.next('c'))) {
    on<UtteranceSubmitted>(
      (e, emit) => _onWorkerText(e.utteranceId, e.text, e.language, emit),
      transformer: droppable(),
    );
    on<TypedMessageSubmitted>(
      (e, emit) => _onWorkerText(_ids.next('u'), e.text, e.language, emit),
      transformer: droppable(),
    );
    on<ReplyRetryRequested>(_onRetry, transformer: restartable());
    on<FinishRequested>(_onFinish);
  }

  final ChatRepository _chat;
  final IdGenerator _ids;

  bool get _acceptsInput => state.phase is Gathering || state.phase is ReplyFailed;

  Future<void> _onWorkerText(String id, String text, Language language, Emitter<ConversationState> emit) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || !_acceptsInput) return;
    if (state.turns.any((t) => t.id == id)) return; // already answered
    // A new message after a failed reply drops the failed attempt.
    final turn = Turn(id: id, speaker: Speaker.worker, text: trimmed, language: language);
    emit(state.copyWith(turns: [...state.turns, turn]));
    await _streamReply(_ids.next('t'), language, emit);
  }

  Future<void> _onRetry(ReplyRetryRequested event, Emitter<ConversationState> emit) async {
    final phase = state.phase;
    if (phase is! ReplyFailed) return;
    final language = state.turns.lastWhere((t) => t.speaker == Speaker.worker).language;
    await _streamReply(phase.turnId, language, emit);
  }

  Future<void> _streamReply(String turnId, Language language, Emitter<ConversationState> emit) async {
    emit(
      state.copyWith(
        phase: ConversationPhase.streaming(turnId: turnId, reply: ''),
      ),
    );
    var reply = '';
    var ended = false;
    await emit.forEach<ChatChunk>(
      _chat.reply(conversationId: state.conversationId, turnId: turnId, language: language, turns: state.turns),
      onData: (chunk) {
        switch (chunk) {
          case ChatDelta(:final text):
            reply += text;
            return state.copyWith(
              phase: ConversationPhase.streaming(turnId: turnId, reply: reply),
            );
          case ChatDone():
            ended = true;
            return _withAssistant(turnId, reply, language);
          case ChatRefused():
            ended = true;
            return _withAssistant(turnId, ConversationStrings.of(language).connectClinician, language);
          case ChatFailed(:final failure):
            ended = true;
            return state.copyWith(
              phase: ConversationPhase.replyFailed(turnId: turnId, failure: failure),
            );
        }
      },
    );
    if (!ended && !isClosed) emit(_withAssistant(turnId, reply, language));
  }

  ConversationState _withAssistant(String turnId, String text, Language language) => state.copyWith(
    turns: [
      ...state.turns,
      Turn(id: turnId, speaker: Speaker.assistant, text: text.trim(), language: language),
    ],
    phase: const ConversationPhase.gathering(),
  );

  void _onFinish(FinishRequested event, Emitter<ConversationState> emit) {
    if (state.phase is! Gathering || !state.turns.any((t) => t.speaker == Speaker.worker)) return;
    emit(state.copyWith(phase: const ConversationPhase.finished()));
  }
}
