// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intake_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IntakeSummaryDto _$IntakeSummaryDtoFromJson(Map<String, dynamic> json) => _IntakeSummaryDto(
  chiefComplaint: json['chief_complaint'] as String?,
  duration: json['duration'] as String?,
  severity: (json['severity'] as num?)?.toInt(),
  symptoms: (json['symptoms'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const <String>[],
  medications: (json['medications'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const <String>[],
  allergies: (json['allergies'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const <String>[],
  redFlags: (json['red_flags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const <String>[],
  language: json['language'] as String,
  openQuestions: (json['open_questions'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const <String>[],
  transcript: json['transcript'] as String,
);

Map<String, dynamic> _$IntakeSummaryDtoToJson(_IntakeSummaryDto instance) => <String, dynamic>{
  'chief_complaint': instance.chiefComplaint,
  'duration': instance.duration,
  'severity': instance.severity,
  'symptoms': instance.symptoms,
  'medications': instance.medications,
  'allergies': instance.allergies,
  'red_flags': instance.redFlags,
  'language': instance.language,
  'open_questions': instance.openQuestions,
  'transcript': instance.transcript,
};
