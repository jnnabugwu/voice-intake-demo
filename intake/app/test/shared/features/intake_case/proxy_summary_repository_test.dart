import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intake/shared/core/failure.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/core/result.dart';
import 'package:intake/shared/features/intake_case/data/intake_summary_dto.dart';
import 'package:intake/shared/features/intake_case/data/proxy_summary_repository.dart';
import 'package:intake/shared/features/intake_case/domain/intake_summary.dart';

void main() {
  // The fixture the proxy's schema is tested against (intake/proxy/test/claude.test.ts).
  final fixture = File('../proxy/contract/summary.example.json').readAsStringSync();

  test('the shared contract fixture parses into an IntakeSummary', () {
    final summary = IntakeSummaryDto.fromJson(jsonDecode(fixture) as Map<String, dynamic>).toDomain();
    expect(summary.chiefComplaint, 'Sore throat that hurts when swallowing');
    expect(summary.severity, 6);
    expect(summary.medications, ['ibuprofen']);
    expect(summary.language, Language.en);
    expect(summary.transcript, startsWith('Worker: Hi, I need to see a doctor today.'));
  });

  test('posts the request and maps the response', () async {
    late Map<String, dynamic> sent;
    final repo = ProxySummaryRepository(
      baseUrl: 'https://proxy.example',
      client: MockClient((request) async {
        sent = jsonDecode(request.body) as Map<String, dynamic>;
        expect(request.url.toString(), 'https://proxy.example/api/summary');
        return http.Response(fixture, 200, headers: {'content-type': 'application/json'});
      }),
    );
    final result = await repo.summarize(conversationId: 'c_1', language: Language.es, transcript: 'Worker: hola');
    expect(sent, {'conversationId': 'c_1', 'language': 'es', 'transcript': 'Worker: hola'});
    expect(result, isA<Ok<IntakeSummary>>());
  });

  test('429 spend_cap, 502 and a malformed body are typed failures', () async {
    Future<Result<IntakeSummary>> answer(int status, String body) => ProxySummaryRepository(
      baseUrl: 'https://p',
      client: MockClient((_) async => http.Response(body, status)),
    ).summarize(conversationId: 'c', language: Language.en, transcript: 't');
    expect(await answer(429, '{"code":"spend_cap"}'), const Err<IntakeSummary>(SpendCapFailure()));
    expect(await answer(502, '{"code":"upstream"}'), const Err<IntakeSummary>(NetworkFailure()));
    expect(await answer(200, '{"language":"en"}'), isA<Err<IntakeSummary>>());
  });
}
