// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'next_step_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NextStepState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NextStepState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'NextStepState()';
}


}

/// @nodoc
class $NextStepStateCopyWith<$Res>  {
$NextStepStateCopyWith(NextStepState _, $Res Function(NextStepState) __);
}


/// Adds pattern-matching-related methods to [NextStepState].
extension NextStepStatePatterns on NextStepState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NextStepNone value)?  none,TResult Function( NextStepLocked value)?  locked,TResult Function( NextStepUnlocked value)?  unlocked,TResult Function( NextStepEscalated value)?  escalated,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NextStepNone() when none != null:
return none(_that);case NextStepLocked() when locked != null:
return locked(_that);case NextStepUnlocked() when unlocked != null:
return unlocked(_that);case NextStepEscalated() when escalated != null:
return escalated(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NextStepNone value)  none,required TResult Function( NextStepLocked value)  locked,required TResult Function( NextStepUnlocked value)  unlocked,required TResult Function( NextStepEscalated value)  escalated,}){
final _that = this;
switch (_that) {
case NextStepNone():
return none(_that);case NextStepLocked():
return locked(_that);case NextStepUnlocked():
return unlocked(_that);case NextStepEscalated():
return escalated(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NextStepNone value)?  none,TResult? Function( NextStepLocked value)?  locked,TResult? Function( NextStepUnlocked value)?  unlocked,TResult? Function( NextStepEscalated value)?  escalated,}){
final _that = this;
switch (_that) {
case NextStepNone() when none != null:
return none(_that);case NextStepLocked() when locked != null:
return locked(_that);case NextStepUnlocked() when unlocked != null:
return unlocked(_that);case NextStepEscalated() when escalated != null:
return escalated(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  none,TResult Function()?  locked,TResult Function( String caseId,  String nextStep,  RedFlag? flag)?  unlocked,TResult Function( RedFlag flag)?  escalated,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NextStepNone() when none != null:
return none();case NextStepLocked() when locked != null:
return locked();case NextStepUnlocked() when unlocked != null:
return unlocked(_that.caseId,_that.nextStep,_that.flag);case NextStepEscalated() when escalated != null:
return escalated(_that.flag);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  none,required TResult Function()  locked,required TResult Function( String caseId,  String nextStep,  RedFlag? flag)  unlocked,required TResult Function( RedFlag flag)  escalated,}) {final _that = this;
switch (_that) {
case NextStepNone():
return none();case NextStepLocked():
return locked();case NextStepUnlocked():
return unlocked(_that.caseId,_that.nextStep,_that.flag);case NextStepEscalated():
return escalated(_that.flag);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  none,TResult? Function()?  locked,TResult? Function( String caseId,  String nextStep,  RedFlag? flag)?  unlocked,TResult? Function( RedFlag flag)?  escalated,}) {final _that = this;
switch (_that) {
case NextStepNone() when none != null:
return none();case NextStepLocked() when locked != null:
return locked();case NextStepUnlocked() when unlocked != null:
return unlocked(_that.caseId,_that.nextStep,_that.flag);case NextStepEscalated() when escalated != null:
return escalated(_that.flag);case _:
  return null;

}
}

}

/// @nodoc


class NextStepNone implements NextStepState {
  const NextStepNone();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NextStepNone);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'NextStepState.none()';
}


}




/// @nodoc


class NextStepLocked implements NextStepState {
  const NextStepLocked();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NextStepLocked);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'NextStepState.locked()';
}


}




/// @nodoc


class NextStepUnlocked implements NextStepState {
  const NextStepUnlocked({required this.caseId, required this.nextStep, this.flag});
  

 final  String caseId;
 final  String nextStep;
 final  RedFlag? flag;

/// Create a copy of NextStepState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NextStepUnlockedCopyWith<NextStepUnlocked> get copyWith => _$NextStepUnlockedCopyWithImpl<NextStepUnlocked>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NextStepUnlocked&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.nextStep, nextStep) || other.nextStep == nextStep)&&(identical(other.flag, flag) || other.flag == flag));
}


@override
int get hashCode {
    return Object.hash(runtimeType,caseId,nextStep,flag);
}

@override
String toString() {
    return 'NextStepState.unlocked(caseId: $caseId, nextStep: $nextStep, flag: $flag)';
}


}

/// @nodoc
abstract mixin class $NextStepUnlockedCopyWith<$Res> implements $NextStepStateCopyWith<$Res> {
  factory $NextStepUnlockedCopyWith(NextStepUnlocked value, $Res Function(NextStepUnlocked) _then) = _$NextStepUnlockedCopyWithImpl;
@useResult
$Res call({
 String caseId, String nextStep, RedFlag? flag
});


$RedFlagCopyWith<$Res>? get flag;

}
/// @nodoc
class _$NextStepUnlockedCopyWithImpl<$Res>
    implements $NextStepUnlockedCopyWith<$Res> {
  _$NextStepUnlockedCopyWithImpl(this._self, this._then);

  final NextStepUnlocked _self;
  final $Res Function(NextStepUnlocked) _then;

/// Create a copy of NextStepState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? caseId = null,Object? nextStep = null,Object? flag = freezed,}) {
  return _then(NextStepUnlocked(
caseId: null == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String,nextStep: null == nextStep ? _self.nextStep : nextStep // ignore: cast_nullable_to_non_nullable
as String,flag: freezed == flag ? _self.flag : flag // ignore: cast_nullable_to_non_nullable
as RedFlag?,
  ));
}

/// Create a copy of NextStepState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RedFlagCopyWith<$Res>? get flag {
    if (_self.flag == null) {
    return null;
  }

  return $RedFlagCopyWith<$Res>(_self.flag!, (value) {
    return _then(_self.copyWith(flag: value));
  });
}
}

/// @nodoc


class NextStepEscalated implements NextStepState {
  const NextStepEscalated({required this.flag});
  

 final  RedFlag flag;

/// Create a copy of NextStepState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NextStepEscalatedCopyWith<NextStepEscalated> get copyWith => _$NextStepEscalatedCopyWithImpl<NextStepEscalated>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NextStepEscalated&&(identical(other.flag, flag) || other.flag == flag));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flag);
}

@override
String toString() {
    return 'NextStepState.escalated(flag: $flag)';
}


}

/// @nodoc
abstract mixin class $NextStepEscalatedCopyWith<$Res> implements $NextStepStateCopyWith<$Res> {
  factory $NextStepEscalatedCopyWith(NextStepEscalated value, $Res Function(NextStepEscalated) _then) = _$NextStepEscalatedCopyWithImpl;
@useResult
$Res call({
 RedFlag flag
});


$RedFlagCopyWith<$Res> get flag;

}
/// @nodoc
class _$NextStepEscalatedCopyWithImpl<$Res>
    implements $NextStepEscalatedCopyWith<$Res> {
  _$NextStepEscalatedCopyWithImpl(this._self, this._then);

  final NextStepEscalated _self;
  final $Res Function(NextStepEscalated) _then;

/// Create a copy of NextStepState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? flag = null,}) {
  return _then(NextStepEscalated(
flag: null == flag ? _self.flag : flag // ignore: cast_nullable_to_non_nullable
as RedFlag,
  ));
}

/// Create a copy of NextStepState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RedFlagCopyWith<$Res> get flag {
  
  return $RedFlagCopyWith<$Res>(_self.flag, (value) {
    return _then(_self.copyWith(flag: value));
  });
}
}

// dart format on
