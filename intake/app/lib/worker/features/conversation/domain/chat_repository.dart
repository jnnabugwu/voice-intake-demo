import 'package:intake/shared/core/language.dart';
import 'package:intake/worker/features/conversation/domain/chat_chunk.dart';
import 'package:intake/worker/features/conversation/domain/turn.dart';

/// Streams the assistant's next reply. Demo mode scripts it; live mode asks
/// the proxy. The assistant gathers and the physician decides: replies
/// acknowledge, ask one follow-up question, and stop.
abstract interface class ChatRepository {
  Stream<ChatChunk> reply({
    required String conversationId,
    required String turnId,
    required Language language,
    required List<Turn> turns,
  });
}
