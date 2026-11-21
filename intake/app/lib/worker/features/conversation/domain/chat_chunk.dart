import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intake/shared/core/failure.dart';
import 'package:intake/shared/features/safety/domain/red_flag.dart';

part 'chat_chunk.freezed.dart';

/// One piece of a streamed reply. A reply stream always ends with [ChatDone],
/// [ChatRefused] or [ChatFailed], never with an error.
@freezed
sealed class ChatChunk with _$ChatChunk {
  const factory ChatChunk.delta(String text) = ChatDelta;
  const factory ChatChunk.done() = ChatDone;

  /// The model declined. The worker is offered a clinician.
  const factory ChatChunk.refused() = ChatRefused;
  const factory ChatChunk.failed(Failure failure) = ChatFailed;

  /// The proxy's own red-flag pass caught something the app's didn't.
  const factory ChatChunk.redFlag(RedFlagKind kind) = ChatRedFlag;
}
