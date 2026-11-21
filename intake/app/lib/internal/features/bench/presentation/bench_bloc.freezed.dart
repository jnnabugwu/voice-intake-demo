// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bench_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BenchState {

 BenchScript? get script; int get speakerIndex;/// 0-based, clamped to the script.
 int get index; bool get listening; String get partial; Map<int, BenchTake> get takes; String? get error;
/// Create a copy of BenchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BenchStateCopyWith<BenchState> get copyWith => _$BenchStateCopyWithImpl<BenchState>(this as BenchState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BenchState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BenchState&&(identical(other.script, _this.script) || other.script == _this.script)&&(identical(other.speakerIndex, _this.speakerIndex) || other.speakerIndex == _this.speakerIndex)&&(identical(other.index, _this.index) || other.index == _this.index)&&(identical(other.listening, _this.listening) || other.listening == _this.listening)&&(identical(other.partial, _this.partial) || other.partial == _this.partial)&&const DeepCollectionEquality().equals(other.takes, _this.takes)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as BenchState;
  return Object.hash(runtimeType,_this.script,_this.speakerIndex,_this.index,_this.listening,_this.partial,const DeepCollectionEquality().hash(_this.takes),_this.error);
}

@override
String toString() {
  final _this = this as BenchState;
  return 'BenchState(script: ${_this.script}, speakerIndex: ${_this.speakerIndex}, index: ${_this.index}, listening: ${_this.listening}, partial: ${_this.partial}, takes: ${_this.takes}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $BenchStateCopyWith<$Res>  {
  factory $BenchStateCopyWith(BenchState value, $Res Function(BenchState) _then) = _$BenchStateCopyWithImpl;
@useResult
$Res call({
 BenchScript? script, int speakerIndex, int index, bool listening, String partial, Map<int, BenchTake> takes, String? error
});


$BenchScriptCopyWith<$Res>? get script;

}
/// @nodoc
class _$BenchStateCopyWithImpl<$Res>
    implements $BenchStateCopyWith<$Res> {
  _$BenchStateCopyWithImpl(this._self, this._then);

  final BenchState _self;
  final $Res Function(BenchState) _then;

/// Create a copy of BenchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? script = freezed,Object? speakerIndex = null,Object? index = null,Object? listening = null,Object? partial = null,Object? takes = null,Object? error = freezed,}) {
  return _then(BenchState(
script: freezed == script ? _self.script : script // ignore: cast_nullable_to_non_nullable
as BenchScript?,speakerIndex: null == speakerIndex ? _self.speakerIndex : speakerIndex // ignore: cast_nullable_to_non_nullable
as int,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,listening: null == listening ? _self.listening : listening // ignore: cast_nullable_to_non_nullable
as bool,partial: null == partial ? _self.partial : partial // ignore: cast_nullable_to_non_nullable
as String,takes: null == takes ? _self.takes : takes // ignore: cast_nullable_to_non_nullable
as Map<int, BenchTake>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of BenchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BenchScriptCopyWith<$Res>? get script {
    if (_self.script == null) {
    return null;
  }

  return $BenchScriptCopyWith<$Res>(_self.script!, (value) {
    return _then(_self.copyWith(script: value));
  });
}
}


/// Adds pattern-matching-related methods to [BenchState].
extension BenchStatePatterns on BenchState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BenchState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BenchState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BenchState value)  $default,){
final _that = this;
switch (_that) {
case _BenchState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BenchState value)?  $default,){
final _that = this;
switch (_that) {
case _BenchState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BenchScript? script,  int speakerIndex,  int index,  bool listening,  String partial,  Map<int, BenchTake> takes,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BenchState() when $default != null:
return $default(_that.script,_that.speakerIndex,_that.index,_that.listening,_that.partial,_that.takes,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BenchScript? script,  int speakerIndex,  int index,  bool listening,  String partial,  Map<int, BenchTake> takes,  String? error)  $default,) {final _that = this;
switch (_that) {
case _BenchState():
return $default(_that.script,_that.speakerIndex,_that.index,_that.listening,_that.partial,_that.takes,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BenchScript? script,  int speakerIndex,  int index,  bool listening,  String partial,  Map<int, BenchTake> takes,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _BenchState() when $default != null:
return $default(_that.script,_that.speakerIndex,_that.index,_that.listening,_that.partial,_that.takes,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _BenchState extends BenchState {
  const _BenchState({this.script, this.speakerIndex = 0, this.index = 0, this.listening = false, this.partial = '',  Map<int, BenchTake> takes = const <int, BenchTake>{}, this.error}): _takes = takes,super._();
  

@override final  BenchScript? script;
@override@JsonKey() final  int speakerIndex;
/// 0-based, clamped to the script.
@override@JsonKey() final  int index;
@override@JsonKey() final  bool listening;
@override@JsonKey() final  String partial;
 final  Map<int, BenchTake> _takes;
@override@JsonKey() Map<int, BenchTake> get takes {
  if (_takes is EqualUnmodifiableMapView) return _takes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_takes);
}

@override final  String? error;

/// Create a copy of BenchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BenchStateCopyWith<_BenchState> get copyWith => __$BenchStateCopyWithImpl<_BenchState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BenchState&&(identical(other.script, script) || other.script == script)&&(identical(other.speakerIndex, speakerIndex) || other.speakerIndex == speakerIndex)&&(identical(other.index, index) || other.index == index)&&(identical(other.listening, listening) || other.listening == listening)&&(identical(other.partial, partial) || other.partial == partial)&&const DeepCollectionEquality().equals(other.takes, _takes)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,script,speakerIndex,index,listening,partial,const DeepCollectionEquality().hash(_takes),error);
}

@override
String toString() {
    return 'BenchState(script: $script, speakerIndex: $speakerIndex, index: $index, listening: $listening, partial: $partial, takes: $takes, error: $error)';
}


}

/// @nodoc
abstract mixin class _$BenchStateCopyWith<$Res> implements $BenchStateCopyWith<$Res> {
  factory _$BenchStateCopyWith(_BenchState value, $Res Function(_BenchState) _then) = __$BenchStateCopyWithImpl;
@override @useResult
$Res call({
 BenchScript? script, int speakerIndex, int index, bool listening, String partial, Map<int, BenchTake> takes, String? error
});


@override $BenchScriptCopyWith<$Res>? get script;

}
/// @nodoc
class __$BenchStateCopyWithImpl<$Res>
    implements _$BenchStateCopyWith<$Res> {
  __$BenchStateCopyWithImpl(this._self, this._then);

  final _BenchState _self;
  final $Res Function(_BenchState) _then;

/// Create a copy of BenchState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? script = freezed,Object? speakerIndex = null,Object? index = null,Object? listening = null,Object? partial = null,Object? takes = null,Object? error = freezed,}) {
  return _then(_BenchState(
script: freezed == script ? _self.script : script // ignore: cast_nullable_to_non_nullable
as BenchScript?,speakerIndex: null == speakerIndex ? _self.speakerIndex : speakerIndex // ignore: cast_nullable_to_non_nullable
as int,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,listening: null == listening ? _self.listening : listening // ignore: cast_nullable_to_non_nullable
as bool,partial: null == partial ? _self.partial : partial // ignore: cast_nullable_to_non_nullable
as String,takes: null == takes ? _self._takes : takes // ignore: cast_nullable_to_non_nullable
as Map<int, BenchTake>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of BenchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BenchScriptCopyWith<$Res>? get script {
    if (_self.script == null) {
    return null;
  }

  return $BenchScriptCopyWith<$Res>(_self.script!, (value) {
    return _then(_self.copyWith(script: value));
  });
}
}

// dart format on
