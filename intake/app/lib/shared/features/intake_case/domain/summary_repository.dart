import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/core/result.dart';
import 'package:intake/shared/features/intake_case/domain/intake_summary.dart';
import 'package:meta/meta.dart';

/// Builds the structured summary: keyword rules in demo mode, the proxy live.
abstract interface class SummaryRepository {
  @useResult
  Future<Result<IntakeSummary>> summarize({
    required String conversationId,
    required Language language,
    required String transcript,
  });
}
