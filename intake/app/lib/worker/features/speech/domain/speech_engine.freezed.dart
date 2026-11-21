// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'speech_engine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SpeechResult {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SpeechResult);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SpeechResult()';
}


}

/// @nodoc
class $SpeechResultCopyWith<$Res>  {
$SpeechResultCopyWith(SpeechResult _, $Res Function(SpeechResult) __);
}


/// Adds pattern-matching-related methods to [SpeechResult].
extension SpeechResultPatterns on SpeechResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SpeechPartial value)?  partial,TResult Function( SpeechCompleted value)?  completed,TResult Function( SpeechFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SpeechPartial() when partial != null:
return partial(_that);case SpeechCompleted() when completed != null:
return completed(_that);case SpeechFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SpeechPartial value)  partial,required TResult Function( SpeechCompleted value)  completed,required TResult Function( SpeechFailed value)  failed,}){
final _that = this;
switch (_that) {
case SpeechPartial():
return partial(_that);case SpeechCompleted():
return completed(_that);case SpeechFailed():
return failed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SpeechPartial value)?  partial,TResult? Function( SpeechCompleted value)?  completed,TResult? Function( SpeechFailed value)?  failed,}){
final _that = this;
switch (_that) {
case SpeechPartial() when partial != null:
return partial(_that);case SpeechCompleted() when completed != null:
return completed(_that);case SpeechFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String text)?  partial,TResult Function( String text)?  completed,TResult Function( Failure failure)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SpeechPartial() when partial != null:
return partial(_that.text);case SpeechCompleted() when completed != null:
return completed(_that.text);case SpeechFailed() when failed != null:
return failed(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String text)  partial,required TResult Function( String text)  completed,required TResult Function( Failure failure)  failed,}) {final _that = this;
switch (_that) {
case SpeechPartial():
return partial(_that.text);case SpeechCompleted():
return completed(_that.text);case SpeechFailed():
return failed(_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String text)?  partial,TResult? Function( String text)?  completed,TResult? Function( Failure failure)?  failed,}) {final _that = this;
switch (_that) {
case SpeechPartial() when partial != null:
return partial(_that.text);case SpeechCompleted() when completed != null:
return completed(_that.text);case SpeechFailed() when failed != null:
return failed(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class SpeechPartial implements SpeechResult {
  const SpeechPartial(this.text);
  

 final  String text;

/// Create a copy of SpeechResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpeechPartialCopyWith<SpeechPartial> get copyWith => _$SpeechPartialCopyWithImpl<SpeechPartial>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SpeechPartial&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode {
    return Object.hash(runtimeType,text);
}

@override
String toString() {
    return 'SpeechResult.partial(text: $text)';
}


}

/// @nodoc
abstract mixin class $SpeechPartialCopyWith<$Res> implements $SpeechResultCopyWith<$Res> {
  factory $SpeechPartialCopyWith(SpeechPartial value, $Res Function(SpeechPartial) _then) = _$SpeechPartialCopyWithImpl;
@useResult
$Res call({
 String text
});




}
/// @nodoc
class _$SpeechPartialCopyWithImpl<$Res>
    implements $SpeechPartialCopyWith<$Res> {
  _$SpeechPartialCopyWithImpl(this._self, this._then);

  final SpeechPartial _self;
  final $Res Function(SpeechPartial) _then;

/// Create a copy of SpeechResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? text = null,}) {
  return _then(SpeechPartial(
null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SpeechCompleted implements SpeechResult {
  const SpeechCompleted(this.text);
  

 final  String text;

/// Create a copy of SpeechResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpeechCompletedCopyWith<SpeechCompleted> get copyWith => _$SpeechCompletedCopyWithImpl<SpeechCompleted>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SpeechCompleted&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode {
    return Object.hash(runtimeType,text);
}

@override
String toString() {
    return 'SpeechResult.completed(text: $text)';
}


}

/// @nodoc
abstract mixin class $SpeechCompletedCopyWith<$Res> implements $SpeechResultCopyWith<$Res> {
  factory $SpeechCompletedCopyWith(SpeechCompleted value, $Res Function(SpeechCompleted) _then) = _$SpeechCompletedCopyWithImpl;
@useResult
$Res call({
 String text
});




}
/// @nodoc
class _$SpeechCompletedCopyWithImpl<$Res>
    implements $SpeechCompletedCopyWith<$Res> {
  _$SpeechCompletedCopyWithImpl(this._self, this._then);

  final SpeechCompleted _self;
  final $Res Function(SpeechCompleted) _then;

/// Create a copy of SpeechResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? text = null,}) {
  return _then(SpeechCompleted(
null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SpeechFailed implements SpeechResult {
  const SpeechFailed(this.failure);
  

 final  Failure failure;

/// Create a copy of SpeechResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpeechFailedCopyWith<SpeechFailed> get copyWith => _$SpeechFailedCopyWithImpl<SpeechFailed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SpeechFailed&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,failure);
}

@override
String toString() {
    return 'SpeechResult.failed(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $SpeechFailedCopyWith<$Res> implements $SpeechResultCopyWith<$Res> {
  factory $SpeechFailedCopyWith(SpeechFailed value, $Res Function(SpeechFailed) _then) = _$SpeechFailedCopyWithImpl;
@useResult
$Res call({
 Failure failure
});




}
/// @nodoc
class _$SpeechFailedCopyWithImpl<$Res>
    implements $SpeechFailedCopyWith<$Res> {
  _$SpeechFailedCopyWithImpl(this._self, this._then);

  final SpeechFailed _self;
  final $Res Function(SpeechFailed) _then;

/// Create a copy of SpeechResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(SpeechFailed(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}


}

// dart format on
