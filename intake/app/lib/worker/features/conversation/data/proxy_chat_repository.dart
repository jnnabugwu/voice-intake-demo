import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intake/shared/core/failure.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/features/safety/domain/red_flag.dart';
import 'package:intake/worker/features/conversation/data/sse_parser.dart';
import 'package:intake/worker/features/conversation/domain/chat_chunk.dart';
import 'package:intake/worker/features/conversation/domain/chat_repository.dart';
import 'package:intake/worker/features/conversation/domain/turn.dart';

/// Live replies from the proxy's `POST /api/chat`, streamed as server-sent
/// events. The wire contract is in ARCHITECTURE.md § Proxy.
class ProxyChatRepository implements ChatRepository {
  ProxyChatRepository({required this.baseUrl, http.Client? client}) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  @override
  Stream<ChatChunk> reply({
    required String conversationId,
    required String turnId,
    required Language language,
    required List<Turn> turns,
  }) async* {
    final request = http.Request('POST', Uri.parse('$baseUrl/api/chat'))
      ..headers['content-type'] = 'application/json'
      ..body = jsonEncode({
        'conversationId': conversationId,
        'turnId': turnId,
        'language': language.code,
        'messages': [
          for (final t in turns) {'role': t.speaker == Speaker.worker ? 'user' : 'assistant', 'text': t.text},
        ],
      });

    final http.StreamedResponse response;
    try {
      response = await _client.send(request);
    } catch (_) {
      yield const ChatChunk.failed(NetworkFailure());
      return;
    }
    if (response.statusCode != 200) {
      yield ChatChunk.failed(failureForStatus(response.statusCode, await _code(response)));
      return;
    }

    try {
      await for (final e in parseSse(response.stream)) {
        final chunk = chunkFor(e);
        if (chunk == null) continue;
        yield chunk;
        if (chunk is! ChatDelta) return; // terminal
      }
    } catch (_) {
      yield const ChatChunk.failed(NetworkFailure());
      return;
    }
    // The connection closed without saying how the reply ended.
    yield const ChatChunk.failed(NetworkFailure());
  }

  /// One SSE event as a chunk; unknown events are skipped.
  static ChatChunk? chunkFor(SseEvent e) => switch (e.event) {
    'delta' => ChatChunk.delta(e.data['text'] as String? ?? ''),
    'done' => const ChatChunk.done(),
    'refusal' => const ChatChunk.refused(),
    'red_flag' => ChatChunk.redFlag(e.data['kind'] == 'crisis' ? RedFlagKind.crisis : RedFlagKind.emergency),
    'error' => ChatChunk.failed(failureForCode(e.data['code'] as String?)),
    _ => null,
  };

  static Future<String?> _code(http.StreamedResponse response) async {
    try {
      final body = jsonDecode(await response.stream.bytesToString());
      return body is Map<String, dynamic> ? body['code'] as String? : null;
    } catch (_) {
      return null;
    }
  }
}

/// The proxy's error codes, shared by both proxy repositories.
Failure failureForCode(String? code) => switch (code) {
  'rate_limited' => const RateLimitedFailure(),
  'spend_cap' => const SpendCapFailure(),
  'upstream' => const NetworkFailure(),
  _ => UnknownFailure(code),
};

Failure failureForStatus(int status, String? code) =>
    code != null ? failureForCode(code) : (status >= 500 ? const NetworkFailure() : UnknownFailure('http_$status'));
