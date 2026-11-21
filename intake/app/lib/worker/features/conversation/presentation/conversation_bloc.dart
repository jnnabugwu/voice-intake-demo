import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intake/shared/core/failure.dart';
import 'package:intake/shared/core/ids.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/core/result.dart';
import 'package:intake/shared/features/safety/domain/red_flag.dart';
import 'package:intake/shared/features/safety/domain/red_flag_detector.dart';
import 'package:intake/worker/features/conversation/domain/chat_chunk.dart';
import 'package:intake/worker/features/conversation/domain/chat_repository.dart';
import 'package:intake/worker/features/conversation/domain/submit_intake.dart';
import 'package:intake/worker/features/conversation/domain/turn.dart';
import 'package:intake/worker/features/conversation/presentation/conversation_event.dart';
import 'package:intake/worker/features/conversation/presentation/conversation_state.dart';
import 'package:intake/worker/features/conversation/presentation/conversation_strings.dart';

export 'package:intake/worker/features/conversation/presentation/conversation_event.dart';
export 'package:intake/worker/features/conversation/presentation/conversation_state.dart';

/// Owns the conversation: the turns, the streaming reply, and finishing the intake.
class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  ConversationBloc(this._chat, this._ids, this._submit, [this._detector = const RedFlagDetector()])
    : super(ConversationState(conversationId: _ids.next('c'))) {
    on<UtteranceSubmitted>(
      (e, emit) => _onWorkerText(e.utteranceId, e.text, e.language, emit),
      transformer: droppable(),
    );
    on<TypedMessageSubmitted>(
      (e, emit) => _onWorkerText(_ids.next('u'), e.text, e.language, emit),
      transformer: droppable(),
    );
    // Droppable, not restartable: a second tap must not cancel the retry in flight.
    on<ReplyRetryRequested>(_onRetry, transformer: droppable());
    on<FinishRequested>(_onFinish, transformer: droppable());
  }

  final ChatRepository _chat;
  final IdGenerator _ids;
  final SubmitIntake _submit;
  final RedFlagDetector _detector;

  bool get _acceptsInput => state.phase is Gathering || state.phase is ReplyFailed;

  Future<void> _onWorkerText(String id, String text, Language language, Emitter<ConversationState> emit) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || !_acceptsInput) return;
    if (state.turns.any((t) => t.id == id)) return; // already answered
    // A new message after a failed reply drops the failed attempt.
    final turn = Turn(id: id, speaker: Speaker.worker, text: trimmed, language: language);
    emit(state.copyWith(turns: [...state.turns, turn]));
    // Red flags stop the chat before any model call.
    final flag = _detector.detect(trimmed, language: language);
    if (flag != null) return _escalate(flag, language, emit);
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
        // The first terminal chunk decides how the reply ended; anything after it is ignored.
        if (ended) return state;
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
            return _withAssistant(
              turnId,
              ConversationStrings.of(language).connectClinician,
              language,
            ).copyWith(clinicianOffered: true);
          case ChatRedFlag(:final kind):
            ended = true;
            // The proxy checked the newest message; that message is the trigger.
            final said = state.turns.lastWhere((t) => t.speaker == Speaker.worker).text;
            final flag = RedFlag(kind: kind, reason: said);
            return state.copyWith(phase: ConversationPhase.redFlagRaised(flag: flag));
          case ChatFailed(:final failure):
            ended = true;
            return state.copyWith(
              phase: ConversationPhase.replyFailed(turnId: turnId, failure: failure),
            );
        }
      },
    );
    // A stream that closed without saying how it ended is a failure the worker can retry.
    if (!ended && !isClosed) {
      emit(
        state.copyWith(
          phase: ConversationPhase.replyFailed(turnId: turnId, failure: const UnknownFailure('stream_ended_early')),
        ),
      );
    }
    if (state.phase case RedFlagRaised(:final flag)) await _submitEscalated(flag, language);
  }

  Future<void> _escalate(RedFlag flag, Language language, Emitter<ConversationState> emit) async {
    emit(state.copyWith(phase: ConversationPhase.redFlagRaised(flag: flag)));
    await _submitEscalated(flag, language);
  }

  /// The physician sees an escalated case right away; the worker sees the
  /// card either way, so a failed submit here can't hide the help lines.
  Future<void> _submitEscalated(RedFlag flag, Language language) async {
    final _ = await _submit(conversationId: state.conversationId, language: language, turns: state.turns, flag: flag);
  }

  ConversationState _withAssistant(String turnId, String text, Language language) => state.copyWith(
    turns: [
      ...state.turns,
      Turn(id: turnId, speaker: Speaker.assistant, text: text.trim(), language: language),
    ],
    phase: const ConversationPhase.gathering(),
  );

  Future<void> _onFinish(FinishRequested event, Emitter<ConversationState> emit) async {
    final canFinish = state.phase is Gathering || state.phase is SubmitFailed;
    if (!canFinish || !state.turns.any((t) => t.speaker == Speaker.worker)) return;
    emit(state.copyWith(phase: const ConversationPhase.finished()));
    final language = state.turns.lastWhere((t) => t.speaker == Speaker.worker).language;
    final result = await _submit(conversationId: state.conversationId, language: language, turns: state.turns);
    if (result case Err(:final failure)) emit(state.copyWith(phase: ConversationPhase.submitFailed(failure: failure)));
  }
}
