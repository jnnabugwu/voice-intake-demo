import 'dart:async';

import 'package:intake/shared/core/language.dart';
import 'package:intake/worker/features/conversation/domain/chat_chunk.dart';
import 'package:intake/worker/features/conversation/domain/chat_repository.dart';
import 'package:intake/worker/features/conversation/domain/turn.dart';

/// Replies with whatever the test queued, one script per call.
class FakeChatRepository implements ChatRepository {
  FakeChatRepository(this.scripts);

  final List<List<ChatChunk>> scripts;
  final calls = <({String turnId, List<Turn> turns})>[];

  @override
  Stream<ChatChunk> reply({
    required String conversationId,
    required String turnId,
    required Language language,
    required List<Turn> turns,
  }) async* {
    calls.add((turnId: turnId, turns: turns));
    for (final chunk in scripts.removeAt(0)) {
      await Future<void>.delayed(Duration.zero);
      yield chunk;
    }
  }
}
