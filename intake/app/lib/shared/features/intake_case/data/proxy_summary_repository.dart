import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intake/shared/core/failure.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/core/result.dart';
import 'package:intake/shared/features/intake_case/data/intake_summary_dto.dart';
import 'package:intake/shared/features/intake_case/domain/intake_summary.dart';
import 'package:intake/shared/features/intake_case/domain/summary_repository.dart';

/// The structured summary from the proxy's `POST /api/summary`.
class ProxySummaryRepository implements SummaryRepository {
  ProxySummaryRepository({required this.baseUrl, http.Client? client}) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  @override
  Future<Result<IntakeSummary>> summarize({
    required String conversationId,
    required Language language,
    required String transcript,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/summary'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'conversationId': conversationId, 'language': language.code, 'transcript': transcript}),
      );
      final body = jsonDecode(response.body);
      if (response.statusCode != 200 || body is! Map<String, dynamic>) {
        final code = body is Map<String, dynamic> ? body['code'] as String? : null;
        return Err(switch (code) {
          'rate_limited' => const RateLimitedFailure(),
          'spend_cap' => const SpendCapFailure(),
          _ => response.statusCode >= 500 ? const NetworkFailure() : UnknownFailure('http_${response.statusCode}'),
        });
      }
      return Ok(IntakeSummaryDto.fromJson(body).toDomain());
    } on FormatException {
      return const Err(UnknownFailure('bad_summary'));
    } on TypeError {
      return const Err(UnknownFailure('bad_summary'));
    } catch (_) {
      return const Err(NetworkFailure());
    }
  }
}
