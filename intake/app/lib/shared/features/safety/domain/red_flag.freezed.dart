// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'red_flag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RedFlag {

 RedFlagKind get kind; String get reason;
/// Create a copy of RedFlag
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RedFlagCopyWith<RedFlag> get copyWith => _$RedFlagCopyWithImpl<RedFlag>(this as RedFlag, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RedFlag;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RedFlag&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.reason, _this.reason) || other.reason == _this.reason));
}


@override
int get hashCode {
  final _this = this as RedFlag;
  return Object.hash(runtimeType,_this.kind,_this.reason);
}

@override
String toString() {
  final _this = this as RedFlag;
  return 'RedFlag(kind: ${_this.kind}, reason: ${_this.reason})';
}


}

/// @nodoc
abstract mixin class $RedFlagCopyWith<$Res>  {
  factory $RedFlagCopyWith(RedFlag value, $Res Function(RedFlag) _then) = _$RedFlagCopyWithImpl;
@useResult
$Res call({
 RedFlagKind kind, String reason
});




}
/// @nodoc
class _$RedFlagCopyWithImpl<$Res>
    implements $RedFlagCopyWith<$Res> {
  _$RedFlagCopyWithImpl(this._self, this._then);

  final RedFlag _self;
  final $Res Function(RedFlag) _then;

/// Create a copy of RedFlag
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? reason = null,}) {
  return _then(RedFlag(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as RedFlagKind,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RedFlag].
extension RedFlagPatterns on RedFlag {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RedFlag value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RedFlag() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RedFlag value)  $default,){
final _that = this;
switch (_that) {
case _RedFlag():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RedFlag value)?  $default,){
final _that = this;
switch (_that) {
case _RedFlag() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RedFlagKind kind,  String reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RedFlag() when $default != null:
return $default(_that.kind,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RedFlagKind kind,  String reason)  $default,) {final _that = this;
switch (_that) {
case _RedFlag():
return $default(_that.kind,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RedFlagKind kind,  String reason)?  $default,) {final _that = this;
switch (_that) {
case _RedFlag() when $default != null:
return $default(_that.kind,_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class _RedFlag implements RedFlag {
  const _RedFlag({required this.kind, required this.reason});
  

@override final  RedFlagKind kind;
@override final  String reason;

/// Create a copy of RedFlag
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RedFlagCopyWith<_RedFlag> get copyWith => __$RedFlagCopyWithImpl<_RedFlag>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RedFlag&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,kind,reason);
}

@override
String toString() {
    return 'RedFlag(kind: $kind, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$RedFlagCopyWith<$Res> implements $RedFlagCopyWith<$Res> {
  factory _$RedFlagCopyWith(_RedFlag value, $Res Function(_RedFlag) _then) = __$RedFlagCopyWithImpl;
@override @useResult
$Res call({
 RedFlagKind kind, String reason
});




}
/// @nodoc
class __$RedFlagCopyWithImpl<$Res>
    implements _$RedFlagCopyWith<$Res> {
  __$RedFlagCopyWithImpl(this._self, this._then);

  final _RedFlag _self;
  final $Res Function(_RedFlag) _then;

/// Create a copy of RedFlag
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? reason = null,}) {
  return _then(_RedFlag(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as RedFlagKind,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
