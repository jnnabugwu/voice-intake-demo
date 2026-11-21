import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intake/shared/core/language.dart';

part 'intake_summary.freezed.dart';

/// What the physician reads first. A field is null (or empty) when the worker
/// didn't say it; nothing is inferred.
@freezed
abstract class IntakeSummary with _$IntakeSummary {
  const factory IntakeSummary({
    String? chiefComplaint,
    String? duration,

    /// 1–10, only if the worker gave a number.
    int? severity,
    @Default(<String>[]) List<String> symptoms,
    @Default(<String>[]) List<String> medications,
    @Default(<String>[]) List<String> allergies,
    @Default(<String>[]) List<String> redFlags,
    required Language language,
    @Default(<String>[]) List<String> openQuestions,
    required String transcript,
  }) = _IntakeSummary;
}
