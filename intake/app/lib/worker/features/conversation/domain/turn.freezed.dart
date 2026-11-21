// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'turn.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Turn {

 String get id; Speaker get speaker; String get text; Language get language;
/// Create a copy of Turn
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TurnCopyWith<Turn> get copyWith => _$TurnCopyWithImpl<Turn>(this as Turn, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Turn;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Turn&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.speaker, _this.speaker) || other.speaker == _this.speaker)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.language, _this.language) || other.language == _this.language));
}


@override
int get hashCode {
  final _this = this as Turn;
  return Object.hash(runtimeType,_this.id,_this.speaker,_this.text,_this.language);
}

@override
String toString() {
  final _this = this as Turn;
  return 'Turn(id: ${_this.id}, speaker: ${_this.speaker}, text: ${_this.text}, language: ${_this.language})';
}


}

/// @nodoc
abstract mixin class $TurnCopyWith<$Res>  {
  factory $TurnCopyWith(Turn value, $Res Function(Turn) _then) = _$TurnCopyWithImpl;
@useResult
$Res call({
 String id, Speaker speaker, String text, Language language
});




}
/// @nodoc
class _$TurnCopyWithImpl<$Res>
    implements $TurnCopyWith<$Res> {
  _$TurnCopyWithImpl(this._self, this._then);

  final Turn _self;
  final $Res Function(Turn) _then;

/// Create a copy of Turn
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? speaker = null,Object? text = null,Object? language = null,}) {
  return _then(Turn(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,speaker: null == speaker ? _self.speaker : speaker // ignore: cast_nullable_to_non_nullable
as Speaker,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as Language,
  ));
}

}


/// Adds pattern-matching-related methods to [Turn].
extension TurnPatterns on Turn {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Turn value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Turn() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Turn value)  $default,){
final _that = this;
switch (_that) {
case _Turn():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Turn value)?  $default,){
final _that = this;
switch (_that) {
case _Turn() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  Speaker speaker,  String text,  Language language)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Turn() when $default != null:
return $default(_that.id,_that.speaker,_that.text,_that.language);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  Speaker speaker,  String text,  Language language)  $default,) {final _that = this;
switch (_that) {
case _Turn():
return $default(_that.id,_that.speaker,_that.text,_that.language);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  Speaker speaker,  String text,  Language language)?  $default,) {final _that = this;
switch (_that) {
case _Turn() when $default != null:
return $default(_that.id,_that.speaker,_that.text,_that.language);case _:
  return null;

}
}

}

/// @nodoc


class _Turn implements Turn {
  const _Turn({required this.id, required this.speaker, required this.text, required this.language});
  

@override final  String id;
@override final  Speaker speaker;
@override final  String text;
@override final  Language language;

/// Create a copy of Turn
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TurnCopyWith<_Turn> get copyWith => __$TurnCopyWithImpl<_Turn>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Turn&&(identical(other.id, id) || other.id == id)&&(identical(other.speaker, speaker) || other.speaker == speaker)&&(identical(other.text, text) || other.text == text)&&(identical(other.language, language) || other.language == language));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,speaker,text,language);
}

@override
String toString() {
    return 'Turn(id: $id, speaker: $speaker, text: $text, language: $language)';
}


}

/// @nodoc
abstract mixin class _$TurnCopyWith<$Res> implements $TurnCopyWith<$Res> {
  factory _$TurnCopyWith(_Turn value, $Res Function(_Turn) _then) = __$TurnCopyWithImpl;
@override @useResult
$Res call({
 String id, Speaker speaker, String text, Language language
});




}
/// @nodoc
class __$TurnCopyWithImpl<$Res>
    implements _$TurnCopyWith<$Res> {
  __$TurnCopyWithImpl(this._self, this._then);

  final _Turn _self;
  final $Res Function(_Turn) _then;

/// Create a copy of Turn
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? speaker = null,Object? text = null,Object? language = null,}) {
  return _then(_Turn(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,speaker: null == speaker ? _self.speaker : speaker // ignore: cast_nullable_to_non_nullable
as Speaker,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as Language,
  ));
}


}

// dart format on
