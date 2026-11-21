// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_chunk.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatChunk {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatChunk);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ChatChunk()';
}


}

/// @nodoc
class $ChatChunkCopyWith<$Res>  {
$ChatChunkCopyWith(ChatChunk _, $Res Function(ChatChunk) __);
}


/// Adds pattern-matching-related methods to [ChatChunk].
extension ChatChunkPatterns on ChatChunk {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ChatDelta value)?  delta,TResult Function( ChatDone value)?  done,TResult Function( ChatRefused value)?  refused,TResult Function( ChatFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ChatDelta() when delta != null:
return delta(_that);case ChatDone() when done != null:
return done(_that);case ChatRefused() when refused != null:
return refused(_that);case ChatFailed() when failed != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ChatDelta value)  delta,required TResult Function( ChatDone value)  done,required TResult Function( ChatRefused value)  refused,required TResult Function( ChatFailed value)  failed,}){
final _that = this;
switch (_that) {
case ChatDelta():
return delta(_that);case ChatDone():
return done(_that);case ChatRefused():
return refused(_that);case ChatFailed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ChatDelta value)?  delta,TResult? Function( ChatDone value)?  done,TResult? Function( ChatRefused value)?  refused,TResult? Function( ChatFailed value)?  failed,}){
final _that = this;
switch (_that) {
case ChatDelta() when delta != null:
return delta(_that);case ChatDone() when done != null:
return done(_that);case ChatRefused() when refused != null:
return refused(_that);case ChatFailed() when failed != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String text)?  delta,TResult Function()?  done,TResult Function()?  refused,TResult Function( Failure failure)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ChatDelta() when delta != null:
return delta(_that.text);case ChatDone() when done != null:
return done();case ChatRefused() when refused != null:
return refused();case ChatFailed() when failed != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String text)  delta,required TResult Function()  done,required TResult Function()  refused,required TResult Function( Failure failure)  failed,}) {final _that = this;
switch (_that) {
case ChatDelta():
return delta(_that.text);case ChatDone():
return done();case ChatRefused():
return refused();case ChatFailed():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String text)?  delta,TResult? Function()?  done,TResult? Function()?  refused,TResult? Function( Failure failure)?  failed,}) {final _that = this;
switch (_that) {
case ChatDelta() when delta != null:
return delta(_that.text);case ChatDone() when done != null:
return done();case ChatRefused() when refused != null:
return refused();case ChatFailed() when failed != null:
return failed(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class ChatDelta implements ChatChunk {
  const ChatDelta(this.text);
  

 final  String text;

/// Create a copy of ChatChunk
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatDeltaCopyWith<ChatDelta> get copyWith => _$ChatDeltaCopyWithImpl<ChatDelta>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatDelta&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode {
    return Object.hash(runtimeType,text);
}

@override
String toString() {
    return 'ChatChunk.delta(text: $text)';
}


}

/// @nodoc
abstract mixin class $ChatDeltaCopyWith<$Res> implements $ChatChunkCopyWith<$Res> {
  factory $ChatDeltaCopyWith(ChatDelta value, $Res Function(ChatDelta) _then) = _$ChatDeltaCopyWithImpl;
@useResult
$Res call({
 String text
});




}
/// @nodoc
class _$ChatDeltaCopyWithImpl<$Res>
    implements $ChatDeltaCopyWith<$Res> {
  _$ChatDeltaCopyWithImpl(this._self, this._then);

  final ChatDelta _self;
  final $Res Function(ChatDelta) _then;

/// Create a copy of ChatChunk
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? text = null,}) {
  return _then(ChatDelta(
null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ChatDone implements ChatChunk {
  const ChatDone();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatDone);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ChatChunk.done()';
}


}




/// @nodoc


class ChatRefused implements ChatChunk {
  const ChatRefused();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatRefused);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ChatChunk.refused()';
}


}




/// @nodoc


class ChatFailed implements ChatChunk {
  const ChatFailed(this.failure);
  

 final  Failure failure;

/// Create a copy of ChatChunk
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatFailedCopyWith<ChatFailed> get copyWith => _$ChatFailedCopyWithImpl<ChatFailed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatFailed&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,failure);
}

@override
String toString() {
    return 'ChatChunk.failed(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $ChatFailedCopyWith<$Res> implements $ChatChunkCopyWith<$Res> {
  factory $ChatFailedCopyWith(ChatFailed value, $Res Function(ChatFailed) _then) = _$ChatFailedCopyWithImpl;
@useResult
$Res call({
 Failure failure
});




}
/// @nodoc
class _$ChatFailedCopyWithImpl<$Res>
    implements $ChatFailedCopyWith<$Res> {
  _$ChatFailedCopyWithImpl(this._self, this._then);

  final ChatFailed _self;
  final $Res Function(ChatFailed) _then;

/// Create a copy of ChatChunk
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(ChatFailed(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}


}

// dart format on
