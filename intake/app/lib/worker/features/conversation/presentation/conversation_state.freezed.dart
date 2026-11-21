// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConversationState {

 String get conversationId; List<Turn> get turns; ConversationPhase get phase;/// The model declined; the worker is offered a clinician and the help lines.
 bool get clinicianOffered;
/// Create a copy of ConversationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationStateCopyWith<ConversationState> get copyWith => _$ConversationStateCopyWithImpl<ConversationState>(this as ConversationState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ConversationState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationState&&(identical(other.conversationId, _this.conversationId) || other.conversationId == _this.conversationId)&&const DeepCollectionEquality().equals(other.turns, _this.turns)&&(identical(other.phase, _this.phase) || other.phase == _this.phase)&&(identical(other.clinicianOffered, _this.clinicianOffered) || other.clinicianOffered == _this.clinicianOffered));
}


@override
int get hashCode {
  final _this = this as ConversationState;
  return Object.hash(runtimeType,_this.conversationId,const DeepCollectionEquality().hash(_this.turns),_this.phase,_this.clinicianOffered);
}

@override
String toString() {
  final _this = this as ConversationState;
  return 'ConversationState(conversationId: ${_this.conversationId}, turns: ${_this.turns}, phase: ${_this.phase}, clinicianOffered: ${_this.clinicianOffered})';
}


}

/// @nodoc
abstract mixin class $ConversationStateCopyWith<$Res>  {
  factory $ConversationStateCopyWith(ConversationState value, $Res Function(ConversationState) _then) = _$ConversationStateCopyWithImpl;
@useResult
$Res call({
 String conversationId, List<Turn> turns, ConversationPhase phase, bool clinicianOffered
});


$ConversationPhaseCopyWith<$Res> get phase;

}
/// @nodoc
class _$ConversationStateCopyWithImpl<$Res>
    implements $ConversationStateCopyWith<$Res> {
  _$ConversationStateCopyWithImpl(this._self, this._then);

  final ConversationState _self;
  final $Res Function(ConversationState) _then;

/// Create a copy of ConversationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conversationId = null,Object? turns = null,Object? phase = null,Object? clinicianOffered = null,}) {
  return _then(ConversationState(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,turns: null == turns ? _self.turns : turns // ignore: cast_nullable_to_non_nullable
as List<Turn>,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as ConversationPhase,clinicianOffered: null == clinicianOffered ? _self.clinicianOffered : clinicianOffered // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ConversationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConversationPhaseCopyWith<$Res> get phase {
  
  return $ConversationPhaseCopyWith<$Res>(_self.phase, (value) {
    return _then(_self.copyWith(phase: value));
  });
}
}


/// Adds pattern-matching-related methods to [ConversationState].
extension ConversationStatePatterns on ConversationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConversationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConversationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConversationState value)  $default,){
final _that = this;
switch (_that) {
case _ConversationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConversationState value)?  $default,){
final _that = this;
switch (_that) {
case _ConversationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String conversationId,  List<Turn> turns,  ConversationPhase phase,  bool clinicianOffered)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConversationState() when $default != null:
return $default(_that.conversationId,_that.turns,_that.phase,_that.clinicianOffered);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String conversationId,  List<Turn> turns,  ConversationPhase phase,  bool clinicianOffered)  $default,) {final _that = this;
switch (_that) {
case _ConversationState():
return $default(_that.conversationId,_that.turns,_that.phase,_that.clinicianOffered);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String conversationId,  List<Turn> turns,  ConversationPhase phase,  bool clinicianOffered)?  $default,) {final _that = this;
switch (_that) {
case _ConversationState() when $default != null:
return $default(_that.conversationId,_that.turns,_that.phase,_that.clinicianOffered);case _:
  return null;

}
}

}

/// @nodoc


class _ConversationState implements ConversationState {
  const _ConversationState({required this.conversationId,  List<Turn> turns = const <Turn>[], this.phase = const ConversationPhase.gathering(), this.clinicianOffered = false}): _turns = turns;
  

@override final  String conversationId;
 final  List<Turn> _turns;
@override@JsonKey() List<Turn> get turns {
  if (_turns is EqualUnmodifiableListView) return _turns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_turns);
}

@override@JsonKey() final  ConversationPhase phase;
/// The model declined; the worker is offered a clinician and the help lines.
@override@JsonKey() final  bool clinicianOffered;

/// Create a copy of ConversationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationStateCopyWith<_ConversationState> get copyWith => __$ConversationStateCopyWithImpl<_ConversationState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConversationState&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&const DeepCollectionEquality().equals(other.turns, _turns)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.clinicianOffered, clinicianOffered) || other.clinicianOffered == clinicianOffered));
}


@override
int get hashCode {
    return Object.hash(runtimeType,conversationId,const DeepCollectionEquality().hash(_turns),phase,clinicianOffered);
}

@override
String toString() {
    return 'ConversationState(conversationId: $conversationId, turns: $turns, phase: $phase, clinicianOffered: $clinicianOffered)';
}


}

/// @nodoc
abstract mixin class _$ConversationStateCopyWith<$Res> implements $ConversationStateCopyWith<$Res> {
  factory _$ConversationStateCopyWith(_ConversationState value, $Res Function(_ConversationState) _then) = __$ConversationStateCopyWithImpl;
@override @useResult
$Res call({
 String conversationId, List<Turn> turns, ConversationPhase phase, bool clinicianOffered
});


@override $ConversationPhaseCopyWith<$Res> get phase;

}
/// @nodoc
class __$ConversationStateCopyWithImpl<$Res>
    implements _$ConversationStateCopyWith<$Res> {
  __$ConversationStateCopyWithImpl(this._self, this._then);

  final _ConversationState _self;
  final $Res Function(_ConversationState) _then;

/// Create a copy of ConversationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conversationId = null,Object? turns = null,Object? phase = null,Object? clinicianOffered = null,}) {
  return _then(_ConversationState(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,turns: null == turns ? _self._turns : turns // ignore: cast_nullable_to_non_nullable
as List<Turn>,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as ConversationPhase,clinicianOffered: null == clinicianOffered ? _self.clinicianOffered : clinicianOffered // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ConversationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConversationPhaseCopyWith<$Res> get phase {
  
  return $ConversationPhaseCopyWith<$Res>(_self.phase, (value) {
    return _then(_self.copyWith(phase: value));
  });
}
}

/// @nodoc
mixin _$ConversationPhase {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationPhase);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConversationPhase()';
}


}

/// @nodoc
class $ConversationPhaseCopyWith<$Res>  {
$ConversationPhaseCopyWith(ConversationPhase _, $Res Function(ConversationPhase) __);
}


/// Adds pattern-matching-related methods to [ConversationPhase].
extension ConversationPhasePatterns on ConversationPhase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Gathering value)?  gathering,TResult Function( Streaming value)?  streaming,TResult Function( ReplyFailed value)?  replyFailed,TResult Function( RedFlagRaised value)?  redFlagRaised,TResult Function( Finished value)?  finished,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Gathering() when gathering != null:
return gathering(_that);case Streaming() when streaming != null:
return streaming(_that);case ReplyFailed() when replyFailed != null:
return replyFailed(_that);case RedFlagRaised() when redFlagRaised != null:
return redFlagRaised(_that);case Finished() when finished != null:
return finished(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Gathering value)  gathering,required TResult Function( Streaming value)  streaming,required TResult Function( ReplyFailed value)  replyFailed,required TResult Function( RedFlagRaised value)  redFlagRaised,required TResult Function( Finished value)  finished,}){
final _that = this;
switch (_that) {
case Gathering():
return gathering(_that);case Streaming():
return streaming(_that);case ReplyFailed():
return replyFailed(_that);case RedFlagRaised():
return redFlagRaised(_that);case Finished():
return finished(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Gathering value)?  gathering,TResult? Function( Streaming value)?  streaming,TResult? Function( ReplyFailed value)?  replyFailed,TResult? Function( RedFlagRaised value)?  redFlagRaised,TResult? Function( Finished value)?  finished,}){
final _that = this;
switch (_that) {
case Gathering() when gathering != null:
return gathering(_that);case Streaming() when streaming != null:
return streaming(_that);case ReplyFailed() when replyFailed != null:
return replyFailed(_that);case RedFlagRaised() when redFlagRaised != null:
return redFlagRaised(_that);case Finished() when finished != null:
return finished(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  gathering,TResult Function( String turnId,  String reply)?  streaming,TResult Function( String turnId,  Failure failure)?  replyFailed,TResult Function( RedFlag flag)?  redFlagRaised,TResult Function()?  finished,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Gathering() when gathering != null:
return gathering();case Streaming() when streaming != null:
return streaming(_that.turnId,_that.reply);case ReplyFailed() when replyFailed != null:
return replyFailed(_that.turnId,_that.failure);case RedFlagRaised() when redFlagRaised != null:
return redFlagRaised(_that.flag);case Finished() when finished != null:
return finished();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  gathering,required TResult Function( String turnId,  String reply)  streaming,required TResult Function( String turnId,  Failure failure)  replyFailed,required TResult Function( RedFlag flag)  redFlagRaised,required TResult Function()  finished,}) {final _that = this;
switch (_that) {
case Gathering():
return gathering();case Streaming():
return streaming(_that.turnId,_that.reply);case ReplyFailed():
return replyFailed(_that.turnId,_that.failure);case RedFlagRaised():
return redFlagRaised(_that.flag);case Finished():
return finished();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  gathering,TResult? Function( String turnId,  String reply)?  streaming,TResult? Function( String turnId,  Failure failure)?  replyFailed,TResult? Function( RedFlag flag)?  redFlagRaised,TResult? Function()?  finished,}) {final _that = this;
switch (_that) {
case Gathering() when gathering != null:
return gathering();case Streaming() when streaming != null:
return streaming(_that.turnId,_that.reply);case ReplyFailed() when replyFailed != null:
return replyFailed(_that.turnId,_that.failure);case RedFlagRaised() when redFlagRaised != null:
return redFlagRaised(_that.flag);case Finished() when finished != null:
return finished();case _:
  return null;

}
}

}

/// @nodoc


class Gathering implements ConversationPhase {
  const Gathering();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Gathering);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConversationPhase.gathering()';
}


}




/// @nodoc


class Streaming implements ConversationPhase {
  const Streaming({required this.turnId, required this.reply});
  

 final  String turnId;
 final  String reply;

/// Create a copy of ConversationPhase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreamingCopyWith<Streaming> get copyWith => _$StreamingCopyWithImpl<Streaming>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Streaming&&(identical(other.turnId, turnId) || other.turnId == turnId)&&(identical(other.reply, reply) || other.reply == reply));
}


@override
int get hashCode {
    return Object.hash(runtimeType,turnId,reply);
}

@override
String toString() {
    return 'ConversationPhase.streaming(turnId: $turnId, reply: $reply)';
}


}

/// @nodoc
abstract mixin class $StreamingCopyWith<$Res> implements $ConversationPhaseCopyWith<$Res> {
  factory $StreamingCopyWith(Streaming value, $Res Function(Streaming) _then) = _$StreamingCopyWithImpl;
@useResult
$Res call({
 String turnId, String reply
});




}
/// @nodoc
class _$StreamingCopyWithImpl<$Res>
    implements $StreamingCopyWith<$Res> {
  _$StreamingCopyWithImpl(this._self, this._then);

  final Streaming _self;
  final $Res Function(Streaming) _then;

/// Create a copy of ConversationPhase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? turnId = null,Object? reply = null,}) {
  return _then(Streaming(
turnId: null == turnId ? _self.turnId : turnId // ignore: cast_nullable_to_non_nullable
as String,reply: null == reply ? _self.reply : reply // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ReplyFailed implements ConversationPhase {
  const ReplyFailed({required this.turnId, required this.failure});
  

 final  String turnId;
 final  Failure failure;

/// Create a copy of ConversationPhase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReplyFailedCopyWith<ReplyFailed> get copyWith => _$ReplyFailedCopyWithImpl<ReplyFailed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ReplyFailed&&(identical(other.turnId, turnId) || other.turnId == turnId)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,turnId,failure);
}

@override
String toString() {
    return 'ConversationPhase.replyFailed(turnId: $turnId, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $ReplyFailedCopyWith<$Res> implements $ConversationPhaseCopyWith<$Res> {
  factory $ReplyFailedCopyWith(ReplyFailed value, $Res Function(ReplyFailed) _then) = _$ReplyFailedCopyWithImpl;
@useResult
$Res call({
 String turnId, Failure failure
});




}
/// @nodoc
class _$ReplyFailedCopyWithImpl<$Res>
    implements $ReplyFailedCopyWith<$Res> {
  _$ReplyFailedCopyWithImpl(this._self, this._then);

  final ReplyFailed _self;
  final $Res Function(ReplyFailed) _then;

/// Create a copy of ConversationPhase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? turnId = null,Object? failure = null,}) {
  return _then(ReplyFailed(
turnId: null == turnId ? _self.turnId : turnId // ignore: cast_nullable_to_non_nullable
as String,failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}


}

/// @nodoc


class RedFlagRaised implements ConversationPhase {
  const RedFlagRaised({required this.flag});
  

 final  RedFlag flag;

/// Create a copy of ConversationPhase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RedFlagRaisedCopyWith<RedFlagRaised> get copyWith => _$RedFlagRaisedCopyWithImpl<RedFlagRaised>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RedFlagRaised&&(identical(other.flag, flag) || other.flag == flag));
}


@override
int get hashCode {
    return Object.hash(runtimeType,flag);
}

@override
String toString() {
    return 'ConversationPhase.redFlagRaised(flag: $flag)';
}


}

/// @nodoc
abstract mixin class $RedFlagRaisedCopyWith<$Res> implements $ConversationPhaseCopyWith<$Res> {
  factory $RedFlagRaisedCopyWith(RedFlagRaised value, $Res Function(RedFlagRaised) _then) = _$RedFlagRaisedCopyWithImpl;
@useResult
$Res call({
 RedFlag flag
});


$RedFlagCopyWith<$Res> get flag;

}
/// @nodoc
class _$RedFlagRaisedCopyWithImpl<$Res>
    implements $RedFlagRaisedCopyWith<$Res> {
  _$RedFlagRaisedCopyWithImpl(this._self, this._then);

  final RedFlagRaised _self;
  final $Res Function(RedFlagRaised) _then;

/// Create a copy of ConversationPhase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? flag = null,}) {
  return _then(RedFlagRaised(
flag: null == flag ? _self.flag : flag // ignore: cast_nullable_to_non_nullable
as RedFlag,
  ));
}

/// Create a copy of ConversationPhase
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RedFlagCopyWith<$Res> get flag {
  
  return $RedFlagCopyWith<$Res>(_self.flag, (value) {
    return _then(_self.copyWith(flag: value));
  });
}
}

/// @nodoc


class Finished implements ConversationPhase {
  const Finished();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Finished);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ConversationPhase.finished()';
}


}




// dart format on
