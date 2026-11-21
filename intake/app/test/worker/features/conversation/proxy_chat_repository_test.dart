import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intake/shared/core/failure.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/features/safety/domain/red_flag.dart';
import 'package:intake/worker/features/conversation/data/proxy_chat_repository.dart';
import 'package:intake/worker/features/conversation/data/sse_parser.dart';
import 'package:intake/worker/features/conversation/domain/chat_chunk.dart';
import 'package:intake/worker/features/conversation/domain/turn.dart';

const _turns = [Turn(id: 'u_1', speaker: Speaker.worker, text: 'My throat hurts', language: Language.en)];

/// A client that answers with these chunks of body, as separate network reads.
MockClient _streaming(List<String> chunks, {int status = 200, void Function(http.Request)? onRequest}) =>
    MockClient.streaming((request, body) async {
      onRequest?.call(request as http.Request);
      return http.StreamedResponse(Stream.fromIterable(chunks.map(utf8.encode)), status);
    });

Future<List<ChatChunk>> _reply(http.Client client) => ProxyChatRepository(
  baseUrl: 'https://proxy.example',
  client: client,
).reply(conversationId: 'c_1', turnId: 't_2', language: Language.en, turns: _turns).toList();

void main() {
  group('parseSse', () {
    test('events split across reads, and several in one read', () async {
      final events = await parseSse(
        Stream.fromIterable(
          [
            'event: delta\ndata: {"te',
            'xt":"How "}\n\nevent: delta\ndata: {"text":"long?"}\n\nevent: done\n',
            'data: {}\n\n',
          ].map(utf8.encode),
        ),
      ).toList();
      expect(events.map((e) => e.event), ['delta', 'delta', 'done']);
      expect(events.first.data['text'], 'How ');
    });

    test('a CRLF split across reads still ends the event', () async {
      final events = await parseSse(
        Stream.fromIterable(
          ['event: delta\r\ndata: {"text":"a"}\r', '\n\r\nevent: done\r\ndata: {}\r\n\r\n'].map(utf8.encode),
        ),
      ).toList();
      expect(events.map((e) => e.event), ['delta', 'done']);
    });

    test('a truncated final block is not an event', () async {
      final events = await parseSse(
        Stream.fromIterable(['event: delta\ndata: {"text":"a"}\n\n', 'event: done\ndata: {}'].map(utf8.encode)),
      ).toList();
      expect(events.map((e) => e.event), ['delta']);
    });

    test('CRLF line endings and malformed data', () async {
      final events = await parseSse(Stream.value(utf8.encode('event: error\r\ndata: {oops\r\n\r\n'))).toList();
      expect(events.single.event, 'error');
      expect(events.single.data, isEmpty);
    });
  });

  group('ProxyChatRepository', () {
    test('sends the wire contract and streams deltas then done', () async {
      late Map<String, dynamic> sent;
      final chunks = await _reply(
        _streaming([
          'event: delta\ndata: {"text":"How "}\n\n',
          'event: delta\ndata: {"text":"long?"}\n\nevent: done\ndata: {}\n\n',
        ], onRequest: (r) => sent = jsonDecode(r.body) as Map<String, dynamic>),
      );
      expect(chunks, const [ChatChunk.delta('How '), ChatChunk.delta('long?'), ChatChunk.done()]);
      expect(sent, {
        'conversationId': 'c_1',
        'turnId': 't_2',
        'language': 'en',
        'messages': [
          {'role': 'user', 'text': 'My throat hurts'},
        ],
      });
    });

    test('refusal, red_flag and error events end the reply', () async {
      expect(await _reply(_streaming(['event: refusal\ndata: {}\n\n'])), const [ChatChunk.refused()]);
      expect(await _reply(_streaming(['event: red_flag\ndata: {"kind":"crisis"}\n\n'])), const [
        ChatChunk.redFlag(RedFlagKind.crisis),
      ]);
      expect(
        await _reply(_streaming(['event: delta\ndata: {"text":"Hi"}\n\nevent: error\ndata: {"code":"upstream"}\n\n'])),
        const [ChatChunk.delta('Hi'), ChatChunk.failed(NetworkFailure())],
      );
    });

    test('a 429 spend_cap body becomes SpendCapFailure; rate_limited becomes RateLimitedFailure', () async {
      expect(await _reply(_streaming(['{"code":"spend_cap"}'], status: 429)), const [
        ChatChunk.failed(SpendCapFailure()),
      ]);
      expect(await _reply(_streaming(['{"code":"rate_limited"}'], status: 429)), const [
        ChatChunk.failed(RateLimitedFailure()),
      ]);
    });

    test('a dropped connection or a stream without an ending is a NetworkFailure, never an error', () async {
      final offline = MockClient.streaming((_, _) async => throw http.ClientException('offline'));
      expect(await _reply(offline), const [ChatChunk.failed(NetworkFailure())]);
      expect(await _reply(_streaming(['event: delta\ndata: {"text":"Hi"}\n\n'])), const [
        ChatChunk.delta('Hi'),
        ChatChunk.failed(NetworkFailure()),
      ]);
    });
  });
}
