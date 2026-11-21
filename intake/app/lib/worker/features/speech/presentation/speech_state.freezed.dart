// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'speech_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SpeechState {

 Language get language;/// The last finished utterance. `WorkerScreen` hands each new one to the
/// conversation once (by ID).
 Utterance? get lastUtterance; SpeechPhase get phase;
/// Create a copy of SpeechState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpeechStateCopyWith<SpeechState> get copyWith => _$SpeechStateCopyWithImpl<SpeechState>(this as SpeechState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SpeechState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpeechState&&(identical(other.language, _this.language) || other.language == _this.language)&&(identical(other.lastUtterance, _this.lastUtterance) || other.lastUtterance == _this.lastUtterance)&&(identical(other.phase, _this.phase) || other.phase == _this.phase));
}


@override
int get hashCode {
  final _this = this as SpeechState;
  return Object.hash(runtimeType,_this.language,_this.lastUtterance,_this.phase);
}

@override
String toString() {
  final _this = this as SpeechState;
  return 'SpeechState(language: ${_this.language}, lastUtterance: ${_this.lastUtterance}, phase: ${_this.phase})';
}


}

/// @nodoc
abstract mixin class $SpeechStateCopyWith<$Res>  {
  factory $SpeechStateCopyWith(SpeechState value, $Res Function(SpeechState) _then) = _$SpeechStateCopyWithImpl;
@useResult
$Res call({
 Language language, Utterance? lastUtterance, SpeechPhase phase
});


$UtteranceCopyWith<$Res>? get lastUtterance;$SpeechPhaseCopyWith<$Res> get phase;

}
/// @nodoc
class _$SpeechStateCopyWithImpl<$Res>
    implements $SpeechStateCopyWith<$Res> {
  _$SpeechStateCopyWithImpl(this._self, this._then);

  final SpeechState _self;
  final $Res Function(SpeechState) _then;

/// Create a copy of SpeechState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? language = null,Object? lastUtterance = freezed,Object? phase = null,}) {
  return _then(SpeechState(
language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as Language,lastUtterance: freezed == lastUtterance ? _self.lastUtterance : lastUtterance // ignore: cast_nullable_to_non_nullable
as Utterance?,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SpeechPhase,
  ));
}
/// Create a copy of SpeechState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UtteranceCopyWith<$Res>? get lastUtterance {
    if (_self.lastUtterance == null) {
    return null;
  }

  return $UtteranceCopyWith<$Res>(_self.lastUtterance!, (value) {
    return _then(_self.copyWith(lastUtterance: value));
  });
}/// Create a copy of SpeechState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpeechPhaseCopyWith<$Res> get phase {
  
  return $SpeechPhaseCopyWith<$Res>(_self.phase, (value) {
    return _then(_self.copyWith(phase: value));
  });
}
}


/// Adds pattern-matching-related methods to [SpeechState].
extension SpeechStatePatterns on SpeechState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpeechState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpeechState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpeechState value)  $default,){
final _that = this;
switch (_that) {
case _SpeechState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpeechState value)?  $default,){
final _that = this;
switch (_that) {
case _SpeechState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Language language,  Utterance? lastUtterance,  SpeechPhase phase)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpeechState() when $default != null:
return $default(_that.language,_that.lastUtterance,_that.phase);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Language language,  Utterance? lastUtterance,  SpeechPhase phase)  $default,) {final _that = this;
switch (_that) {
case _SpeechState():
return $default(_that.language,_that.lastUtterance,_that.phase);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Language language,  Utterance? lastUtterance,  SpeechPhase phase)?  $default,) {final _that = this;
switch (_that) {
case _SpeechState() when $default != null:
return $default(_that.language,_that.lastUtterance,_that.phase);case _:
  return null;

}
}

}

/// @nodoc


class _SpeechState implements SpeechState {
  const _SpeechState({this.language = Language.en, this.lastUtterance, this.phase = const SpeechPhase.idle()});
  

@override@JsonKey() final  Language language;
/// The last finished utterance. `WorkerScreen` hands each new one to the
/// conversation once (by ID).
@override final  Utterance? lastUtterance;
@override@JsonKey() final  SpeechPhase phase;

/// Create a copy of SpeechState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpeechStateCopyWith<_SpeechState> get copyWith => __$SpeechStateCopyWithImpl<_SpeechState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpeechState&&(identical(other.language, language) || other.language == language)&&(identical(other.lastUtterance, lastUtterance) || other.lastUtterance == lastUtterance)&&(identical(other.phase, phase) || other.phase == phase));
}


@override
int get hashCode {
    return Object.hash(runtimeType,language,lastUtterance,phase);
}

@override
String toString() {
    return 'SpeechState(language: $language, lastUtterance: $lastUtterance, phase: $phase)';
}


}

/// @nodoc
abstract mixin class _$SpeechStateCopyWith<$Res> implements $SpeechStateCopyWith<$Res> {
  factory _$SpeechStateCopyWith(_SpeechState value, $Res Function(_SpeechState) _then) = __$SpeechStateCopyWithImpl;
@override @useResult
$Res call({
 Language language, Utterance? lastUtterance, SpeechPhase phase
});


@override $UtteranceCopyWith<$Res>? get lastUtterance;@override $SpeechPhaseCopyWith<$Res> get phase;

}
/// @nodoc
class __$SpeechStateCopyWithImpl<$Res>
    implements _$SpeechStateCopyWith<$Res> {
  __$SpeechStateCopyWithImpl(this._self, this._then);

  final _SpeechState _self;
  final $Res Function(_SpeechState) _then;

/// Create a copy of SpeechState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? language = null,Object? lastUtterance = freezed,Object? phase = null,}) {
  return _then(_SpeechState(
language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as Language,lastUtterance: freezed == lastUtterance ? _self.lastUtterance : lastUtterance // ignore: cast_nullable_to_non_nullable
as Utterance?,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SpeechPhase,
  ));
}

/// Create a copy of SpeechState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UtteranceCopyWith<$Res>? get lastUtterance {
    if (_self.lastUtterance == null) {
    return null;
  }

  return $UtteranceCopyWith<$Res>(_self.lastUtterance!, (value) {
    return _then(_self.copyWith(lastUtterance: value));
  });
}/// Create a copy of SpeechState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpeechPhaseCopyWith<$Res> get phase {
  
  return $SpeechPhaseCopyWith<$Res>(_self.phase, (value) {
    return _then(_self.copyWith(phase: value));
  });
}
}

/// @nodoc
mixin _$SpeechPhase {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SpeechPhase);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SpeechPhase()';
}


}

/// @nodoc
class $SpeechPhaseCopyWith<$Res>  {
$SpeechPhaseCopyWith(SpeechPhase _, $Res Function(SpeechPhase) __);
}


/// Adds pattern-matching-related methods to [SpeechPhase].
extension SpeechPhasePatterns on SpeechPhase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SpeechIdle value)?  idle,TResult Function( SpeechStarting value)?  starting,TResult Function( SpeechListening value)?  listening,TResult Function( SpeechUnavailable value)?  unavailable,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SpeechIdle() when idle != null:
return idle(_that);case SpeechStarting() when starting != null:
return starting(_that);case SpeechListening() when listening != null:
return listening(_that);case SpeechUnavailable() when unavailable != null:
return unavailable(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SpeechIdle value)  idle,required TResult Function( SpeechStarting value)  starting,required TResult Function( SpeechListening value)  listening,required TResult Function( SpeechUnavailable value)  unavailable,}){
final _that = this;
switch (_that) {
case SpeechIdle():
return idle(_that);case SpeechStarting():
return starting(_that);case SpeechListening():
return listening(_that);case SpeechUnavailable():
return unavailable(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SpeechIdle value)?  idle,TResult? Function( SpeechStarting value)?  starting,TResult? Function( SpeechListening value)?  listening,TResult? Function( SpeechUnavailable value)?  unavailable,}){
final _that = this;
switch (_that) {
case SpeechIdle() when idle != null:
return idle(_that);case SpeechStarting() when starting != null:
return starting(_that);case SpeechListening() when listening != null:
return listening(_that);case SpeechUnavailable() when unavailable != null:
return unavailable(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  starting,TResult Function( String partial)?  listening,TResult Function( Failure failure)?  unavailable,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SpeechIdle() when idle != null:
return idle();case SpeechStarting() when starting != null:
return starting();case SpeechListening() when listening != null:
return listening(_that.partial);case SpeechUnavailable() when unavailable != null:
return unavailable(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  starting,required TResult Function( String partial)  listening,required TResult Function( Failure failure)  unavailable,}) {final _that = this;
switch (_that) {
case SpeechIdle():
return idle();case SpeechStarting():
return starting();case SpeechListening():
return listening(_that.partial);case SpeechUnavailable():
return unavailable(_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  starting,TResult? Function( String partial)?  listening,TResult? Function( Failure failure)?  unavailable,}) {final _that = this;
switch (_that) {
case SpeechIdle() when idle != null:
return idle();case SpeechStarting() when starting != null:
return starting();case SpeechListening() when listening != null:
return listening(_that.partial);case SpeechUnavailable() when unavailable != null:
return unavailable(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class SpeechIdle implements SpeechPhase {
  const SpeechIdle();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SpeechIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SpeechPhase.idle()';
}


}




/// @nodoc


class SpeechStarting implements SpeechPhase {
  const SpeechStarting();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SpeechStarting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SpeechPhase.starting()';
}


}




/// @nodoc


class SpeechListening implements SpeechPhase {
  const SpeechListening({required this.partial});
  

 final  String partial;

/// Create a copy of SpeechPhase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpeechListeningCopyWith<SpeechListening> get copyWith => _$SpeechListeningCopyWithImpl<SpeechListening>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SpeechListening&&(identical(other.partial, partial) || other.partial == partial));
}


@override
int get hashCode {
    return Object.hash(runtimeType,partial);
}

@override
String toString() {
    return 'SpeechPhase.listening(partial: $partial)';
}


}

/// @nodoc
abstract mixin class $SpeechListeningCopyWith<$Res> implements $SpeechPhaseCopyWith<$Res> {
  factory $SpeechListeningCopyWith(SpeechListening value, $Res Function(SpeechListening) _then) = _$SpeechListeningCopyWithImpl;
@useResult
$Res call({
 String partial
});




}
/// @nodoc
class _$SpeechListeningCopyWithImpl<$Res>
    implements $SpeechListeningCopyWith<$Res> {
  _$SpeechListeningCopyWithImpl(this._self, this._then);

  final SpeechListening _self;
  final $Res Function(SpeechListening) _then;

/// Create a copy of SpeechPhase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? partial = null,}) {
  return _then(SpeechListening(
partial: null == partial ? _self.partial : partial // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SpeechUnavailable implements SpeechPhase {
  const SpeechUnavailable({required this.failure});
  

 final  Failure failure;

/// Create a copy of SpeechPhase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpeechUnavailableCopyWith<SpeechUnavailable> get copyWith => _$SpeechUnavailableCopyWithImpl<SpeechUnavailable>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SpeechUnavailable&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,failure);
}

@override
String toString() {
    return 'SpeechPhase.unavailable(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $SpeechUnavailableCopyWith<$Res> implements $SpeechPhaseCopyWith<$Res> {
  factory $SpeechUnavailableCopyWith(SpeechUnavailable value, $Res Function(SpeechUnavailable) _then) = _$SpeechUnavailableCopyWithImpl;
@useResult
$Res call({
 Failure failure
});




}
/// @nodoc
class _$SpeechUnavailableCopyWithImpl<$Res>
    implements $SpeechUnavailableCopyWith<$Res> {
  _$SpeechUnavailableCopyWithImpl(this._self, this._then);

  final SpeechUnavailable _self;
  final $Res Function(SpeechUnavailable) _then;

/// Create a copy of SpeechPhase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(SpeechUnavailable(
failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}


}

// dart format on
