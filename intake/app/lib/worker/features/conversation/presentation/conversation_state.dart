import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intake/shared/core/failure.dart';
import 'package:intake/worker/features/conversation/domain/turn.dart';

part 'conversation_state.freezed.dart';

/// The turns stay on screen while a reply streams, fails, retries or
/// escalates, so they sit beside the sealed [phase].
@freezed
abstract class ConversationState with _$ConversationState {
  const factory ConversationState({
    required String conversationId,
    @Default(<Turn>[]) List<Turn> turns,
    @Default(ConversationPhase.gathering()) ConversationPhase phase,
  }) = _ConversationState;
}

@freezed
sealed class ConversationPhase with _$ConversationPhase {
  const factory ConversationPhase.gathering() = Gathering;

  /// [turnId] is the assistant turn being written; [reply] is the text so far.
  const factory ConversationPhase.streaming({required String turnId, required String reply}) = Streaming;
  const factory ConversationPhase.replyFailed({required String turnId, required Failure failure}) = ReplyFailed;
  const factory ConversationPhase.finished() = Finished;
}
