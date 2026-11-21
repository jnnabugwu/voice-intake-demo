// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'intake_summary_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IntakeSummaryDto {

 String? get chiefComplaint; String? get duration; int? get severity; List<String> get symptoms; List<String> get medications; List<String> get allergies; List<String> get redFlags; String get language; List<String> get openQuestions; String get transcript;
/// Create a copy of IntakeSummaryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IntakeSummaryDtoCopyWith<IntakeSummaryDto> get copyWith => _$IntakeSummaryDtoCopyWithImpl<IntakeSummaryDto>(this as IntakeSummaryDto, _$identity);

  /// Serializes this IntakeSummaryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as IntakeSummaryDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IntakeSummaryDto&&(identical(other.chiefComplaint, _this.chiefComplaint) || other.chiefComplaint == _this.chiefComplaint)&&(identical(other.duration, _this.duration) || other.duration == _this.duration)&&(identical(other.severity, _this.severity) || other.severity == _this.severity)&&const DeepCollectionEquality().equals(other.symptoms, _this.symptoms)&&const DeepCollectionEquality().equals(other.medications, _this.medications)&&const DeepCollectionEquality().equals(other.allergies, _this.allergies)&&const DeepCollectionEquality().equals(other.redFlags, _this.redFlags)&&(identical(other.language, _this.language) || other.language == _this.language)&&const DeepCollectionEquality().equals(other.openQuestions, _this.openQuestions)&&(identical(other.transcript, _this.transcript) || other.transcript == _this.transcript));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as IntakeSummaryDto;
  return Object.hash(runtimeType,_this.chiefComplaint,_this.duration,_this.severity,const DeepCollectionEquality().hash(_this.symptoms),const DeepCollectionEquality().hash(_this.medications),const DeepCollectionEquality().hash(_this.allergies),const DeepCollectionEquality().hash(_this.redFlags),_this.language,const DeepCollectionEquality().hash(_this.openQuestions),_this.transcript);
}

@override
String toString() {
  final _this = this as IntakeSummaryDto;
  return 'IntakeSummaryDto(chiefComplaint: ${_this.chiefComplaint}, duration: ${_this.duration}, severity: ${_this.severity}, symptoms: ${_this.symptoms}, medications: ${_this.medications}, allergies: ${_this.allergies}, redFlags: ${_this.redFlags}, language: ${_this.language}, openQuestions: ${_this.openQuestions}, transcript: ${_this.transcript})';
}


}

/// @nodoc
abstract mixin class $IntakeSummaryDtoCopyWith<$Res>  {
  factory $IntakeSummaryDtoCopyWith(IntakeSummaryDto value, $Res Function(IntakeSummaryDto) _then) = _$IntakeSummaryDtoCopyWithImpl;
@useResult
$Res call({
 String? chiefComplaint, String? duration, int? severity, List<String> symptoms, List<String> medications, List<String> allergies, List<String> redFlags, String language, List<String> openQuestions, String transcript
});




}
/// @nodoc
class _$IntakeSummaryDtoCopyWithImpl<$Res>
    implements $IntakeSummaryDtoCopyWith<$Res> {
  _$IntakeSummaryDtoCopyWithImpl(this._self, this._then);

  final IntakeSummaryDto _self;
  final $Res Function(IntakeSummaryDto) _then;

/// Create a copy of IntakeSummaryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chiefComplaint = freezed,Object? duration = freezed,Object? severity = freezed,Object? symptoms = null,Object? medications = null,Object? allergies = null,Object? redFlags = null,Object? language = null,Object? openQuestions = null,Object? transcript = null,}) {
  return _then(IntakeSummaryDto(
chiefComplaint: freezed == chiefComplaint ? _self.chiefComplaint : chiefComplaint // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String?,severity: freezed == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as int?,symptoms: null == symptoms ? _self.symptoms : symptoms // ignore: cast_nullable_to_non_nullable
as List<String>,medications: null == medications ? _self.medications : medications // ignore: cast_nullable_to_non_nullable
as List<String>,allergies: null == allergies ? _self.allergies : allergies // ignore: cast_nullable_to_non_nullable
as List<String>,redFlags: null == redFlags ? _self.redFlags : redFlags // ignore: cast_nullable_to_non_nullable
as List<String>,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,openQuestions: null == openQuestions ? _self.openQuestions : openQuestions // ignore: cast_nullable_to_non_nullable
as List<String>,transcript: null == transcript ? _self.transcript : transcript // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [IntakeSummaryDto].
extension IntakeSummaryDtoPatterns on IntakeSummaryDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IntakeSummaryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IntakeSummaryDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IntakeSummaryDto value)  $default,){
final _that = this;
switch (_that) {
case _IntakeSummaryDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IntakeSummaryDto value)?  $default,){
final _that = this;
switch (_that) {
case _IntakeSummaryDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? chiefComplaint,  String? duration,  int? severity,  List<String> symptoms,  List<String> medications,  List<String> allergies,  List<String> redFlags,  String language,  List<String> openQuestions,  String transcript)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IntakeSummaryDto() when $default != null:
return $default(_that.chiefComplaint,_that.duration,_that.severity,_that.symptoms,_that.medications,_that.allergies,_that.redFlags,_that.language,_that.openQuestions,_that.transcript);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? chiefComplaint,  String? duration,  int? severity,  List<String> symptoms,  List<String> medications,  List<String> allergies,  List<String> redFlags,  String language,  List<String> openQuestions,  String transcript)  $default,) {final _that = this;
switch (_that) {
case _IntakeSummaryDto():
return $default(_that.chiefComplaint,_that.duration,_that.severity,_that.symptoms,_that.medications,_that.allergies,_that.redFlags,_that.language,_that.openQuestions,_that.transcript);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? chiefComplaint,  String? duration,  int? severity,  List<String> symptoms,  List<String> medications,  List<String> allergies,  List<String> redFlags,  String language,  List<String> openQuestions,  String transcript)?  $default,) {final _that = this;
switch (_that) {
case _IntakeSummaryDto() when $default != null:
return $default(_that.chiefComplaint,_that.duration,_that.severity,_that.symptoms,_that.medications,_that.allergies,_that.redFlags,_that.language,_that.openQuestions,_that.transcript);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _IntakeSummaryDto extends IntakeSummaryDto {
  const _IntakeSummaryDto({this.chiefComplaint, this.duration, this.severity,  List<String> symptoms = const <String>[],  List<String> medications = const <String>[],  List<String> allergies = const <String>[],  List<String> redFlags = const <String>[], required this.language,  List<String> openQuestions = const <String>[], required this.transcript}): _symptoms = symptoms,_medications = medications,_allergies = allergies,_redFlags = redFlags,_openQuestions = openQuestions,super._();
  factory _IntakeSummaryDto.fromJson(Map<String, dynamic> json) => _$IntakeSummaryDtoFromJson(json);

@override final  String? chiefComplaint;
@override final  String? duration;
@override final  int? severity;
 final  List<String> _symptoms;
@override@JsonKey() List<String> get symptoms {
  if (_symptoms is EqualUnmodifiableListView) return _symptoms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_symptoms);
}

 final  List<String> _medications;
@override@JsonKey() List<String> get medications {
  if (_medications is EqualUnmodifiableListView) return _medications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_medications);
}

 final  List<String> _allergies;
@override@JsonKey() List<String> get allergies {
  if (_allergies is EqualUnmodifiableListView) return _allergies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allergies);
}

 final  List<String> _redFlags;
@override@JsonKey() List<String> get redFlags {
  if (_redFlags is EqualUnmodifiableListView) return _redFlags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_redFlags);
}

@override final  String language;
 final  List<String> _openQuestions;
@override@JsonKey() List<String> get openQuestions {
  if (_openQuestions is EqualUnmodifiableListView) return _openQuestions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_openQuestions);
}

@override final  String transcript;

/// Create a copy of IntakeSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IntakeSummaryDtoCopyWith<_IntakeSummaryDto> get copyWith => __$IntakeSummaryDtoCopyWithImpl<_IntakeSummaryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IntakeSummaryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IntakeSummaryDto&&(identical(other.chiefComplaint, chiefComplaint) || other.chiefComplaint == chiefComplaint)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.severity, severity) || other.severity == severity)&&const DeepCollectionEquality().equals(other.symptoms, _symptoms)&&const DeepCollectionEquality().equals(other.medications, _medications)&&const DeepCollectionEquality().equals(other.allergies, _allergies)&&const DeepCollectionEquality().equals(other.redFlags, _redFlags)&&(identical(other.language, language) || other.language == language)&&const DeepCollectionEquality().equals(other.openQuestions, _openQuestions)&&(identical(other.transcript, transcript) || other.transcript == transcript));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,chiefComplaint,duration,severity,const DeepCollectionEquality().hash(_symptoms),const DeepCollectionEquality().hash(_medications),const DeepCollectionEquality().hash(_allergies),const DeepCollectionEquality().hash(_redFlags),language,const DeepCollectionEquality().hash(_openQuestions),transcript);
}

@override
String toString() {
    return 'IntakeSummaryDto(chiefComplaint: $chiefComplaint, duration: $duration, severity: $severity, symptoms: $symptoms, medications: $medications, allergies: $allergies, redFlags: $redFlags, language: $language, openQuestions: $openQuestions, transcript: $transcript)';
}


}

/// @nodoc
abstract mixin class _$IntakeSummaryDtoCopyWith<$Res> implements $IntakeSummaryDtoCopyWith<$Res> {
  factory _$IntakeSummaryDtoCopyWith(_IntakeSummaryDto value, $Res Function(_IntakeSummaryDto) _then) = __$IntakeSummaryDtoCopyWithImpl;
@override @useResult
$Res call({
 String? chiefComplaint, String? duration, int? severity, List<String> symptoms, List<String> medications, List<String> allergies, List<String> redFlags, String language, List<String> openQuestions, String transcript
});




}
/// @nodoc
class __$IntakeSummaryDtoCopyWithImpl<$Res>
    implements _$IntakeSummaryDtoCopyWith<$Res> {
  __$IntakeSummaryDtoCopyWithImpl(this._self, this._then);

  final _IntakeSummaryDto _self;
  final $Res Function(_IntakeSummaryDto) _then;

/// Create a copy of IntakeSummaryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chiefComplaint = freezed,Object? duration = freezed,Object? severity = freezed,Object? symptoms = null,Object? medications = null,Object? allergies = null,Object? redFlags = null,Object? language = null,Object? openQuestions = null,Object? transcript = null,}) {
  return _then(_IntakeSummaryDto(
chiefComplaint: freezed == chiefComplaint ? _self.chiefComplaint : chiefComplaint // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String?,severity: freezed == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as int?,symptoms: null == symptoms ? _self._symptoms : symptoms // ignore: cast_nullable_to_non_nullable
as List<String>,medications: null == medications ? _self._medications : medications // ignore: cast_nullable_to_non_nullable
as List<String>,allergies: null == allergies ? _self._allergies : allergies // ignore: cast_nullable_to_non_nullable
as List<String>,redFlags: null == redFlags ? _self._redFlags : redFlags // ignore: cast_nullable_to_non_nullable
as List<String>,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,openQuestions: null == openQuestions ? _self._openQuestions : openQuestions // ignore: cast_nullable_to_non_nullable
as List<String>,transcript: null == transcript ? _self.transcript : transcript // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
