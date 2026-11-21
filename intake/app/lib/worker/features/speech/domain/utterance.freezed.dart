// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'utterance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Utterance {

 String get id; String get text; Language get language;
/// Create a copy of Utterance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UtteranceCopyWith<Utterance> get copyWith => _$UtteranceCopyWithImpl<Utterance>(this as Utterance, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Utterance;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Utterance&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.language, _this.language) || other.language == _this.language));
}


@override
int get hashCode {
  final _this = this as Utterance;
  return Object.hash(runtimeType,_this.id,_this.text,_this.language);
}

@override
String toString() {
  final _this = this as Utterance;
  return 'Utterance(id: ${_this.id}, text: ${_this.text}, language: ${_this.language})';
}


}

/// @nodoc
abstract mixin class $UtteranceCopyWith<$Res>  {
  factory $UtteranceCopyWith(Utterance value, $Res Function(Utterance) _then) = _$UtteranceCopyWithImpl;
@useResult
$Res call({
 String id, String text, Language language
});




}
/// @nodoc
class _$UtteranceCopyWithImpl<$Res>
    implements $UtteranceCopyWith<$Res> {
  _$UtteranceCopyWithImpl(this._self, this._then);

  final Utterance _self;
  final $Res Function(Utterance) _then;

/// Create a copy of Utterance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? text = null,Object? language = null,}) {
  return _then(Utterance(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as Language,
  ));
}

}


/// Adds pattern-matching-related methods to [Utterance].
extension UtterancePatterns on Utterance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Utterance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Utterance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Utterance value)  $default,){
final _that = this;
switch (_that) {
case _Utterance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Utterance value)?  $default,){
final _that = this;
switch (_that) {
case _Utterance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String text,  Language language)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Utterance() when $default != null:
return $default(_that.id,_that.text,_that.language);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String text,  Language language)  $default,) {final _that = this;
switch (_that) {
case _Utterance():
return $default(_that.id,_that.text,_that.language);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String text,  Language language)?  $default,) {final _that = this;
switch (_that) {
case _Utterance() when $default != null:
return $default(_that.id,_that.text,_that.language);case _:
  return null;

}
}

}

/// @nodoc


class _Utterance implements Utterance {
  const _Utterance({required this.id, required this.text, required this.language});
  

@override final  String id;
@override final  String text;
@override final  Language language;

/// Create a copy of Utterance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UtteranceCopyWith<_Utterance> get copyWith => __$UtteranceCopyWithImpl<_Utterance>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Utterance&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.language, language) || other.language == language));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,text,language);
}

@override
String toString() {
    return 'Utterance(id: $id, text: $text, language: $language)';
}


}

/// @nodoc
abstract mixin class _$UtteranceCopyWith<$Res> implements $UtteranceCopyWith<$Res> {
  factory _$UtteranceCopyWith(_Utterance value, $Res Function(_Utterance) _then) = __$UtteranceCopyWithImpl;
@override @useResult
$Res call({
 String id, String text, Language language
});




}
/// @nodoc
class __$UtteranceCopyWithImpl<$Res>
    implements _$UtteranceCopyWith<$Res> {
  __$UtteranceCopyWithImpl(this._self, this._then);

  final _Utterance _self;
  final $Res Function(_Utterance) _then;

/// Create a copy of Utterance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? language = null,}) {
  return _then(_Utterance(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as Language,
  ));
}


}

// dart format on
