import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/features/intake_case/domain/intake_summary.dart';

part 'intake_summary_dto.freezed.dart';
part 'intake_summary_dto.g.dart';

/// `/api/summary`'s JSON, as in `intake/proxy/contract/summary.example.json`.
@freezed
abstract class IntakeSummaryDto with _$IntakeSummaryDto {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory IntakeSummaryDto({
    String? chiefComplaint,
    String? duration,
    int? severity,
    @Default(<String>[]) List<String> symptoms,
    @Default(<String>[]) List<String> medications,
    @Default(<String>[]) List<String> allergies,
    @Default(<String>[]) List<String> redFlags,
    required String language,
    @Default(<String>[]) List<String> openQuestions,
    required String transcript,
  }) = _IntakeSummaryDto;

  const IntakeSummaryDto._();

  factory IntakeSummaryDto.fromJson(Map<String, dynamic> json) => _$IntakeSummaryDtoFromJson(json);

  IntakeSummary toDomain() => IntakeSummary(
    chiefComplaint: chiefComplaint,
    duration: duration,
    // The proxy validates 1–10; anything else is treated as not said.
    severity: severity != null && severity! >= 1 && severity! <= 10 ? severity : null,
    symptoms: symptoms,
    medications: medications,
    allergies: allergies,
    redFlags: redFlags,
    language: Language.fromCode(language),
    openQuestions: openQuestions,
    transcript: transcript,
  );
}
