// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'intake_case.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TranscriptLine {

 TranscriptSpeaker get speaker; String get text;
/// Create a copy of TranscriptLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranscriptLineCopyWith<TranscriptLine> get copyWith => _$TranscriptLineCopyWithImpl<TranscriptLine>(this as TranscriptLine, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TranscriptLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranscriptLine&&(identical(other.speaker, _this.speaker) || other.speaker == _this.speaker)&&(identical(other.text, _this.text) || other.text == _this.text));
}


@override
int get hashCode {
  final _this = this as TranscriptLine;
  return Object.hash(runtimeType,_this.speaker,_this.text);
}

@override
String toString() {
  final _this = this as TranscriptLine;
  return 'TranscriptLine(speaker: ${_this.speaker}, text: ${_this.text})';
}


}

/// @nodoc
abstract mixin class $TranscriptLineCopyWith<$Res>  {
  factory $TranscriptLineCopyWith(TranscriptLine value, $Res Function(TranscriptLine) _then) = _$TranscriptLineCopyWithImpl;
@useResult
$Res call({
 TranscriptSpeaker speaker, String text
});




}
/// @nodoc
class _$TranscriptLineCopyWithImpl<$Res>
    implements $TranscriptLineCopyWith<$Res> {
  _$TranscriptLineCopyWithImpl(this._self, this._then);

  final TranscriptLine _self;
  final $Res Function(TranscriptLine) _then;

/// Create a copy of TranscriptLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? speaker = null,Object? text = null,}) {
  return _then(TranscriptLine(
speaker: null == speaker ? _self.speaker : speaker // ignore: cast_nullable_to_non_nullable
as TranscriptSpeaker,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TranscriptLine].
extension TranscriptLinePatterns on TranscriptLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranscriptLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranscriptLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranscriptLine value)  $default,){
final _that = this;
switch (_that) {
case _TranscriptLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranscriptLine value)?  $default,){
final _that = this;
switch (_that) {
case _TranscriptLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TranscriptSpeaker speaker,  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranscriptLine() when $default != null:
return $default(_that.speaker,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TranscriptSpeaker speaker,  String text)  $default,) {final _that = this;
switch (_that) {
case _TranscriptLine():
return $default(_that.speaker,_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TranscriptSpeaker speaker,  String text)?  $default,) {final _that = this;
switch (_that) {
case _TranscriptLine() when $default != null:
return $default(_that.speaker,_that.text);case _:
  return null;

}
}

}

/// @nodoc


class _TranscriptLine implements TranscriptLine {
  const _TranscriptLine({required this.speaker, required this.text});
  

@override final  TranscriptSpeaker speaker;
@override final  String text;

/// Create a copy of TranscriptLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranscriptLineCopyWith<_TranscriptLine> get copyWith => __$TranscriptLineCopyWithImpl<_TranscriptLine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranscriptLine&&(identical(other.speaker, speaker) || other.speaker == speaker)&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode {
    return Object.hash(runtimeType,speaker,text);
}

@override
String toString() {
    return 'TranscriptLine(speaker: $speaker, text: $text)';
}


}

/// @nodoc
abstract mixin class _$TranscriptLineCopyWith<$Res> implements $TranscriptLineCopyWith<$Res> {
  factory _$TranscriptLineCopyWith(_TranscriptLine value, $Res Function(_TranscriptLine) _then) = __$TranscriptLineCopyWithImpl;
@override @useResult
$Res call({
 TranscriptSpeaker speaker, String text
});




}
/// @nodoc
class __$TranscriptLineCopyWithImpl<$Res>
    implements _$TranscriptLineCopyWith<$Res> {
  __$TranscriptLineCopyWithImpl(this._self, this._then);

  final _TranscriptLine _self;
  final $Res Function(_TranscriptLine) _then;

/// Create a copy of TranscriptLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? speaker = null,Object? text = null,}) {
  return _then(_TranscriptLine(
speaker: null == speaker ? _self.speaker : speaker // ignore: cast_nullable_to_non_nullable
as TranscriptSpeaker,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CaseStatus {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is CaseStatus);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CaseStatus()';
}


}

/// @nodoc
class $CaseStatusCopyWith<$Res>  {
$CaseStatusCopyWith(CaseStatus _, $Res Function(CaseStatus) __);
}


/// Adds pattern-matching-related methods to [CaseStatus].
extension CaseStatusPatterns on CaseStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AwaitingReview value)?  awaitingReview,TResult Function( Approved value)?  approved,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AwaitingReview() when awaitingReview != null:
return awaitingReview(_that);case Approved() when approved != null:
return approved(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AwaitingReview value)  awaitingReview,required TResult Function( Approved value)  approved,}){
final _that = this;
switch (_that) {
case AwaitingReview():
return awaitingReview(_that);case Approved():
return approved(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AwaitingReview value)?  awaitingReview,TResult? Function( Approved value)?  approved,}){
final _that = this;
switch (_that) {
case AwaitingReview() when awaitingReview != null:
return awaitingReview(_that);case Approved() when approved != null:
return approved(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  awaitingReview,TResult Function( String nextStep)?  approved,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AwaitingReview() when awaitingReview != null:
return awaitingReview();case Approved() when approved != null:
return approved(_that.nextStep);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  awaitingReview,required TResult Function( String nextStep)  approved,}) {final _that = this;
switch (_that) {
case AwaitingReview():
return awaitingReview();case Approved():
return approved(_that.nextStep);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  awaitingReview,TResult? Function( String nextStep)?  approved,}) {final _that = this;
switch (_that) {
case AwaitingReview() when awaitingReview != null:
return awaitingReview();case Approved() when approved != null:
return approved(_that.nextStep);case _:
  return null;

}
}

}

/// @nodoc


class AwaitingReview implements CaseStatus {
  const AwaitingReview();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AwaitingReview);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'CaseStatus.awaitingReview()';
}


}




/// @nodoc


class Approved implements CaseStatus {
  const Approved({required this.nextStep});
  

 final  String nextStep;

/// Create a copy of CaseStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApprovedCopyWith<Approved> get copyWith => _$ApprovedCopyWithImpl<Approved>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Approved&&(identical(other.nextStep, nextStep) || other.nextStep == nextStep));
}


@override
int get hashCode {
    return Object.hash(runtimeType,nextStep);
}

@override
String toString() {
    return 'CaseStatus.approved(nextStep: $nextStep)';
}


}

/// @nodoc
abstract mixin class $ApprovedCopyWith<$Res> implements $CaseStatusCopyWith<$Res> {
  factory $ApprovedCopyWith(Approved value, $Res Function(Approved) _then) = _$ApprovedCopyWithImpl;
@useResult
$Res call({
 String nextStep
});




}
/// @nodoc
class _$ApprovedCopyWithImpl<$Res>
    implements $ApprovedCopyWith<$Res> {
  _$ApprovedCopyWithImpl(this._self, this._then);

  final Approved _self;
  final $Res Function(Approved) _then;

/// Create a copy of CaseStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? nextStep = null,}) {
  return _then(Approved(
nextStep: null == nextStep ? _self.nextStep : nextStep // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$IntakeCase {

 String get id; Language get language; List<TranscriptLine> get transcript;/// Null when the summary couldn't be built; the physician still has the transcript.
 IntakeSummary? get summary; CaseStatus get status;/// Set when the chat stopped on a red flag and the worker was shown
/// 911 / 988. A record of what happened, so approving the case keeps it.
 RedFlag? get redFlag;
/// Create a copy of IntakeCase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IntakeCaseCopyWith<IntakeCase> get copyWith => _$IntakeCaseCopyWithImpl<IntakeCase>(this as IntakeCase, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as IntakeCase;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IntakeCase&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.language, _this.language) || other.language == _this.language)&&const DeepCollectionEquality().equals(other.transcript, _this.transcript)&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.redFlag, _this.redFlag) || other.redFlag == _this.redFlag));
}


@override
int get hashCode {
  final _this = this as IntakeCase;
  return Object.hash(runtimeType,_this.id,_this.language,const DeepCollectionEquality().hash(_this.transcript),_this.summary,_this.status,_this.redFlag);
}

@override
String toString() {
  final _this = this as IntakeCase;
  return 'IntakeCase(id: ${_this.id}, language: ${_this.language}, transcript: ${_this.transcript}, summary: ${_this.summary}, status: ${_this.status}, redFlag: ${_this.redFlag})';
}


}

/// @nodoc
abstract mixin class $IntakeCaseCopyWith<$Res>  {
  factory $IntakeCaseCopyWith(IntakeCase value, $Res Function(IntakeCase) _then) = _$IntakeCaseCopyWithImpl;
@useResult
$Res call({
 String id, Language language, List<TranscriptLine> transcript, IntakeSummary? summary, CaseStatus status, RedFlag? redFlag
});


$IntakeSummaryCopyWith<$Res>? get summary;$CaseStatusCopyWith<$Res> get status;$RedFlagCopyWith<$Res>? get redFlag;

}
/// @nodoc
class _$IntakeCaseCopyWithImpl<$Res>
    implements $IntakeCaseCopyWith<$Res> {
  _$IntakeCaseCopyWithImpl(this._self, this._then);

  final IntakeCase _self;
  final $Res Function(IntakeCase) _then;

/// Create a copy of IntakeCase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? language = null,Object? transcript = null,Object? summary = freezed,Object? status = null,Object? redFlag = freezed,}) {
  return _then(IntakeCase(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as Language,transcript: null == transcript ? _self.transcript : transcript // ignore: cast_nullable_to_non_nullable
as List<TranscriptLine>,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as IntakeSummary?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CaseStatus,redFlag: freezed == redFlag ? _self.redFlag : redFlag // ignore: cast_nullable_to_non_nullable
as RedFlag?,
  ));
}
/// Create a copy of IntakeCase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IntakeSummaryCopyWith<$Res>? get summary {
    if (_self.summary == null) {
    return null;
  }

  return $IntakeSummaryCopyWith<$Res>(_self.summary!, (value) {
    return _then(_self.copyWith(summary: value));
  });
}/// Create a copy of IntakeCase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CaseStatusCopyWith<$Res> get status {
  
  return $CaseStatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of IntakeCase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RedFlagCopyWith<$Res>? get redFlag {
    if (_self.redFlag == null) {
    return null;
  }

  return $RedFlagCopyWith<$Res>(_self.redFlag!, (value) {
    return _then(_self.copyWith(redFlag: value));
  });
}
}


/// Adds pattern-matching-related methods to [IntakeCase].
extension IntakeCasePatterns on IntakeCase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IntakeCase value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IntakeCase() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IntakeCase value)  $default,){
final _that = this;
switch (_that) {
case _IntakeCase():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IntakeCase value)?  $default,){
final _that = this;
switch (_that) {
case _IntakeCase() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  Language language,  List<TranscriptLine> transcript,  IntakeSummary? summary,  CaseStatus status,  RedFlag? redFlag)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IntakeCase() when $default != null:
return $default(_that.id,_that.language,_that.transcript,_that.summary,_that.status,_that.redFlag);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  Language language,  List<TranscriptLine> transcript,  IntakeSummary? summary,  CaseStatus status,  RedFlag? redFlag)  $default,) {final _that = this;
switch (_that) {
case _IntakeCase():
return $default(_that.id,_that.language,_that.transcript,_that.summary,_that.status,_that.redFlag);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  Language language,  List<TranscriptLine> transcript,  IntakeSummary? summary,  CaseStatus status,  RedFlag? redFlag)?  $default,) {final _that = this;
switch (_that) {
case _IntakeCase() when $default != null:
return $default(_that.id,_that.language,_that.transcript,_that.summary,_that.status,_that.redFlag);case _:
  return null;

}
}

}

/// @nodoc


class _IntakeCase implements IntakeCase {
  const _IntakeCase({required this.id, required this.language, required  List<TranscriptLine> transcript, this.summary, this.status = const CaseStatus.awaitingReview(), this.redFlag}): _transcript = transcript;
  

@override final  String id;
@override final  Language language;
 final  List<TranscriptLine> _transcript;
@override List<TranscriptLine> get transcript {
  if (_transcript is EqualUnmodifiableListView) return _transcript;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transcript);
}

/// Null when the summary couldn't be built; the physician still has the transcript.
@override final  IntakeSummary? summary;
@override@JsonKey() final  CaseStatus status;
/// Set when the chat stopped on a red flag and the worker was shown
/// 911 / 988. A record of what happened, so approving the case keeps it.
@override final  RedFlag? redFlag;

/// Create a copy of IntakeCase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IntakeCaseCopyWith<_IntakeCase> get copyWith => __$IntakeCaseCopyWithImpl<_IntakeCase>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IntakeCase&&(identical(other.id, id) || other.id == id)&&(identical(other.language, language) || other.language == language)&&const DeepCollectionEquality().equals(other.transcript, _transcript)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.status, status) || other.status == status)&&(identical(other.redFlag, redFlag) || other.redFlag == redFlag));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,language,const DeepCollectionEquality().hash(_transcript),summary,status,redFlag);
}

@override
String toString() {
    return 'IntakeCase(id: $id, language: $language, transcript: $transcript, summary: $summary, status: $status, redFlag: $redFlag)';
}


}

/// @nodoc
abstract mixin class _$IntakeCaseCopyWith<$Res> implements $IntakeCaseCopyWith<$Res> {
  factory _$IntakeCaseCopyWith(_IntakeCase value, $Res Function(_IntakeCase) _then) = __$IntakeCaseCopyWithImpl;
@override @useResult
$Res call({
 String id, Language language, List<TranscriptLine> transcript, IntakeSummary? summary, CaseStatus status, RedFlag? redFlag
});


@override $IntakeSummaryCopyWith<$Res>? get summary;@override $CaseStatusCopyWith<$Res> get status;@override $RedFlagCopyWith<$Res>? get redFlag;

}
/// @nodoc
class __$IntakeCaseCopyWithImpl<$Res>
    implements _$IntakeCaseCopyWith<$Res> {
  __$IntakeCaseCopyWithImpl(this._self, this._then);

  final _IntakeCase _self;
  final $Res Function(_IntakeCase) _then;

/// Create a copy of IntakeCase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? language = null,Object? transcript = null,Object? summary = freezed,Object? status = null,Object? redFlag = freezed,}) {
  return _then(_IntakeCase(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as Language,transcript: null == transcript ? _self._transcript : transcript // ignore: cast_nullable_to_non_nullable
as List<TranscriptLine>,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as IntakeSummary?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CaseStatus,redFlag: freezed == redFlag ? _self.redFlag : redFlag // ignore: cast_nullable_to_non_nullable
as RedFlag?,
  ));
}

/// Create a copy of IntakeCase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IntakeSummaryCopyWith<$Res>? get summary {
    if (_self.summary == null) {
    return null;
  }

  return $IntakeSummaryCopyWith<$Res>(_self.summary!, (value) {
    return _then(_self.copyWith(summary: value));
  });
}/// Create a copy of IntakeCase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CaseStatusCopyWith<$Res> get status {
  
  return $CaseStatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of IntakeCase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RedFlagCopyWith<$Res>? get redFlag {
    if (_self.redFlag == null) {
    return null;
  }

  return $RedFlagCopyWith<$Res>(_self.redFlag!, (value) {
    return _then(_self.copyWith(redFlag: value));
  });
}
}

// dart format on
