// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bench.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BenchSpeaker {

 String get id; String get locale; Language get language;
/// Create a copy of BenchSpeaker
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BenchSpeakerCopyWith<BenchSpeaker> get copyWith => _$BenchSpeakerCopyWithImpl<BenchSpeaker>(this as BenchSpeaker, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BenchSpeaker;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BenchSpeaker&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.locale, _this.locale) || other.locale == _this.locale)&&(identical(other.language, _this.language) || other.language == _this.language));
}


@override
int get hashCode {
  final _this = this as BenchSpeaker;
  return Object.hash(runtimeType,_this.id,_this.locale,_this.language);
}

@override
String toString() {
  final _this = this as BenchSpeaker;
  return 'BenchSpeaker(id: ${_this.id}, locale: ${_this.locale}, language: ${_this.language})';
}


}

/// @nodoc
abstract mixin class $BenchSpeakerCopyWith<$Res>  {
  factory $BenchSpeakerCopyWith(BenchSpeaker value, $Res Function(BenchSpeaker) _then) = _$BenchSpeakerCopyWithImpl;
@useResult
$Res call({
 String id, String locale, Language language
});




}
/// @nodoc
class _$BenchSpeakerCopyWithImpl<$Res>
    implements $BenchSpeakerCopyWith<$Res> {
  _$BenchSpeakerCopyWithImpl(this._self, this._then);

  final BenchSpeaker _self;
  final $Res Function(BenchSpeaker) _then;

/// Create a copy of BenchSpeaker
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? locale = null,Object? language = null,}) {
  return _then(BenchSpeaker(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as Language,
  ));
}

}


/// Adds pattern-matching-related methods to [BenchSpeaker].
extension BenchSpeakerPatterns on BenchSpeaker {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BenchSpeaker value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BenchSpeaker() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BenchSpeaker value)  $default,){
final _that = this;
switch (_that) {
case _BenchSpeaker():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BenchSpeaker value)?  $default,){
final _that = this;
switch (_that) {
case _BenchSpeaker() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String locale,  Language language)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BenchSpeaker() when $default != null:
return $default(_that.id,_that.locale,_that.language);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String locale,  Language language)  $default,) {final _that = this;
switch (_that) {
case _BenchSpeaker():
return $default(_that.id,_that.locale,_that.language);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String locale,  Language language)?  $default,) {final _that = this;
switch (_that) {
case _BenchSpeaker() when $default != null:
return $default(_that.id,_that.locale,_that.language);case _:
  return null;

}
}

}

/// @nodoc


class _BenchSpeaker implements BenchSpeaker {
  const _BenchSpeaker({required this.id, required this.locale, required this.language});
  

@override final  String id;
@override final  String locale;
@override final  Language language;

/// Create a copy of BenchSpeaker
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BenchSpeakerCopyWith<_BenchSpeaker> get copyWith => __$BenchSpeakerCopyWithImpl<_BenchSpeaker>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BenchSpeaker&&(identical(other.id, id) || other.id == id)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.language, language) || other.language == language));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,locale,language);
}

@override
String toString() {
    return 'BenchSpeaker(id: $id, locale: $locale, language: $language)';
}


}

/// @nodoc
abstract mixin class _$BenchSpeakerCopyWith<$Res> implements $BenchSpeakerCopyWith<$Res> {
  factory _$BenchSpeakerCopyWith(_BenchSpeaker value, $Res Function(_BenchSpeaker) _then) = __$BenchSpeakerCopyWithImpl;
@override @useResult
$Res call({
 String id, String locale, Language language
});




}
/// @nodoc
class __$BenchSpeakerCopyWithImpl<$Res>
    implements _$BenchSpeakerCopyWith<$Res> {
  __$BenchSpeakerCopyWithImpl(this._self, this._then);

  final _BenchSpeaker _self;
  final $Res Function(_BenchSpeaker) _then;

/// Create a copy of BenchSpeaker
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? locale = null,Object? language = null,}) {
  return _then(_BenchSpeaker(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as Language,
  ));
}


}

/// @nodoc
mixin _$BenchLine {

 int get n; String get en; String get es;
/// Create a copy of BenchLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BenchLineCopyWith<BenchLine> get copyWith => _$BenchLineCopyWithImpl<BenchLine>(this as BenchLine, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BenchLine;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BenchLine&&(identical(other.n, _this.n) || other.n == _this.n)&&(identical(other.en, _this.en) || other.en == _this.en)&&(identical(other.es, _this.es) || other.es == _this.es));
}


@override
int get hashCode {
  final _this = this as BenchLine;
  return Object.hash(runtimeType,_this.n,_this.en,_this.es);
}

@override
String toString() {
  final _this = this as BenchLine;
  return 'BenchLine(n: ${_this.n}, en: ${_this.en}, es: ${_this.es})';
}


}

/// @nodoc
abstract mixin class $BenchLineCopyWith<$Res>  {
  factory $BenchLineCopyWith(BenchLine value, $Res Function(BenchLine) _then) = _$BenchLineCopyWithImpl;
@useResult
$Res call({
 int n, String en, String es
});




}
/// @nodoc
class _$BenchLineCopyWithImpl<$Res>
    implements $BenchLineCopyWith<$Res> {
  _$BenchLineCopyWithImpl(this._self, this._then);

  final BenchLine _self;
  final $Res Function(BenchLine) _then;

/// Create a copy of BenchLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? n = null,Object? en = null,Object? es = null,}) {
  return _then(BenchLine(
n: null == n ? _self.n : n // ignore: cast_nullable_to_non_nullable
as int,en: null == en ? _self.en : en // ignore: cast_nullable_to_non_nullable
as String,es: null == es ? _self.es : es // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BenchLine].
extension BenchLinePatterns on BenchLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BenchLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BenchLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BenchLine value)  $default,){
final _that = this;
switch (_that) {
case _BenchLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BenchLine value)?  $default,){
final _that = this;
switch (_that) {
case _BenchLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int n,  String en,  String es)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BenchLine() when $default != null:
return $default(_that.n,_that.en,_that.es);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int n,  String en,  String es)  $default,) {final _that = this;
switch (_that) {
case _BenchLine():
return $default(_that.n,_that.en,_that.es);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int n,  String en,  String es)?  $default,) {final _that = this;
switch (_that) {
case _BenchLine() when $default != null:
return $default(_that.n,_that.en,_that.es);case _:
  return null;

}
}

}

/// @nodoc


class _BenchLine implements BenchLine {
  const _BenchLine({required this.n, required this.en, required this.es});
  

@override final  int n;
@override final  String en;
@override final  String es;

/// Create a copy of BenchLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BenchLineCopyWith<_BenchLine> get copyWith => __$BenchLineCopyWithImpl<_BenchLine>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BenchLine&&(identical(other.n, n) || other.n == n)&&(identical(other.en, en) || other.en == en)&&(identical(other.es, es) || other.es == es));
}


@override
int get hashCode {
    return Object.hash(runtimeType,n,en,es);
}

@override
String toString() {
    return 'BenchLine(n: $n, en: $en, es: $es)';
}


}

/// @nodoc
abstract mixin class _$BenchLineCopyWith<$Res> implements $BenchLineCopyWith<$Res> {
  factory _$BenchLineCopyWith(_BenchLine value, $Res Function(_BenchLine) _then) = __$BenchLineCopyWithImpl;
@override @useResult
$Res call({
 int n, String en, String es
});




}
/// @nodoc
class __$BenchLineCopyWithImpl<$Res>
    implements _$BenchLineCopyWith<$Res> {
  __$BenchLineCopyWithImpl(this._self, this._then);

  final _BenchLine _self;
  final $Res Function(_BenchLine) _then;

/// Create a copy of BenchLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? n = null,Object? en = null,Object? es = null,}) {
  return _then(_BenchLine(
n: null == n ? _self.n : n // ignore: cast_nullable_to_non_nullable
as int,en: null == en ? _self.en : en // ignore: cast_nullable_to_non_nullable
as String,es: null == es ? _self.es : es // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$BenchScript {

 List<BenchSpeaker> get speakers; List<BenchLine> get lines;
/// Create a copy of BenchScript
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BenchScriptCopyWith<BenchScript> get copyWith => _$BenchScriptCopyWithImpl<BenchScript>(this as BenchScript, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BenchScript;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BenchScript&&const DeepCollectionEquality().equals(other.speakers, _this.speakers)&&const DeepCollectionEquality().equals(other.lines, _this.lines));
}


@override
int get hashCode {
  final _this = this as BenchScript;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.speakers),const DeepCollectionEquality().hash(_this.lines));
}

@override
String toString() {
  final _this = this as BenchScript;
  return 'BenchScript(speakers: ${_this.speakers}, lines: ${_this.lines})';
}


}

/// @nodoc
abstract mixin class $BenchScriptCopyWith<$Res>  {
  factory $BenchScriptCopyWith(BenchScript value, $Res Function(BenchScript) _then) = _$BenchScriptCopyWithImpl;
@useResult
$Res call({
 List<BenchSpeaker> speakers, List<BenchLine> lines
});




}
/// @nodoc
class _$BenchScriptCopyWithImpl<$Res>
    implements $BenchScriptCopyWith<$Res> {
  _$BenchScriptCopyWithImpl(this._self, this._then);

  final BenchScript _self;
  final $Res Function(BenchScript) _then;

/// Create a copy of BenchScript
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? speakers = null,Object? lines = null,}) {
  return _then(BenchScript(
speakers: null == speakers ? _self.speakers : speakers // ignore: cast_nullable_to_non_nullable
as List<BenchSpeaker>,lines: null == lines ? _self.lines : lines // ignore: cast_nullable_to_non_nullable
as List<BenchLine>,
  ));
}

}


/// Adds pattern-matching-related methods to [BenchScript].
extension BenchScriptPatterns on BenchScript {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BenchScript value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BenchScript() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BenchScript value)  $default,){
final _that = this;
switch (_that) {
case _BenchScript():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BenchScript value)?  $default,){
final _that = this;
switch (_that) {
case _BenchScript() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<BenchSpeaker> speakers,  List<BenchLine> lines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BenchScript() when $default != null:
return $default(_that.speakers,_that.lines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<BenchSpeaker> speakers,  List<BenchLine> lines)  $default,) {final _that = this;
switch (_that) {
case _BenchScript():
return $default(_that.speakers,_that.lines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<BenchSpeaker> speakers,  List<BenchLine> lines)?  $default,) {final _that = this;
switch (_that) {
case _BenchScript() when $default != null:
return $default(_that.speakers,_that.lines);case _:
  return null;

}
}

}

/// @nodoc


class _BenchScript implements BenchScript {
  const _BenchScript({required  List<BenchSpeaker> speakers, required  List<BenchLine> lines}): _speakers = speakers,_lines = lines;
  

 final  List<BenchSpeaker> _speakers;
@override List<BenchSpeaker> get speakers {
  if (_speakers is EqualUnmodifiableListView) return _speakers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_speakers);
}

 final  List<BenchLine> _lines;
@override List<BenchLine> get lines {
  if (_lines is EqualUnmodifiableListView) return _lines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lines);
}


/// Create a copy of BenchScript
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BenchScriptCopyWith<_BenchScript> get copyWith => __$BenchScriptCopyWithImpl<_BenchScript>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BenchScript&&const DeepCollectionEquality().equals(other.speakers, _speakers)&&const DeepCollectionEquality().equals(other.lines, _lines));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_speakers),const DeepCollectionEquality().hash(_lines));
}

@override
String toString() {
    return 'BenchScript(speakers: $speakers, lines: $lines)';
}


}

/// @nodoc
abstract mixin class _$BenchScriptCopyWith<$Res> implements $BenchScriptCopyWith<$Res> {
  factory _$BenchScriptCopyWith(_BenchScript value, $Res Function(_BenchScript) _then) = __$BenchScriptCopyWithImpl;
@override @useResult
$Res call({
 List<BenchSpeaker> speakers, List<BenchLine> lines
});




}
/// @nodoc
class __$BenchScriptCopyWithImpl<$Res>
    implements _$BenchScriptCopyWith<$Res> {
  __$BenchScriptCopyWithImpl(this._self, this._then);

  final _BenchScript _self;
  final $Res Function(_BenchScript) _then;

/// Create a copy of BenchScript
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? speakers = null,Object? lines = null,}) {
  return _then(_BenchScript(
speakers: null == speakers ? _self._speakers : speakers // ignore: cast_nullable_to_non_nullable
as List<BenchSpeaker>,lines: null == lines ? _self._lines : lines // ignore: cast_nullable_to_non_nullable
as List<BenchLine>,
  ));
}


}

/// @nodoc
mixin _$BenchTake {

 int get n; String get transcript; int get micOnMs; int? get firstPartialMs; int? get finalMs;
/// Create a copy of BenchTake
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BenchTakeCopyWith<BenchTake> get copyWith => _$BenchTakeCopyWithImpl<BenchTake>(this as BenchTake, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BenchTake;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BenchTake&&(identical(other.n, _this.n) || other.n == _this.n)&&(identical(other.transcript, _this.transcript) || other.transcript == _this.transcript)&&(identical(other.micOnMs, _this.micOnMs) || other.micOnMs == _this.micOnMs)&&(identical(other.firstPartialMs, _this.firstPartialMs) || other.firstPartialMs == _this.firstPartialMs)&&(identical(other.finalMs, _this.finalMs) || other.finalMs == _this.finalMs));
}


@override
int get hashCode {
  final _this = this as BenchTake;
  return Object.hash(runtimeType,_this.n,_this.transcript,_this.micOnMs,_this.firstPartialMs,_this.finalMs);
}

@override
String toString() {
  final _this = this as BenchTake;
  return 'BenchTake(n: ${_this.n}, transcript: ${_this.transcript}, micOnMs: ${_this.micOnMs}, firstPartialMs: ${_this.firstPartialMs}, finalMs: ${_this.finalMs})';
}


}

/// @nodoc
abstract mixin class $BenchTakeCopyWith<$Res>  {
  factory $BenchTakeCopyWith(BenchTake value, $Res Function(BenchTake) _then) = _$BenchTakeCopyWithImpl;
@useResult
$Res call({
 int n, String transcript, int micOnMs, int? firstPartialMs, int? finalMs
});




}
/// @nodoc
class _$BenchTakeCopyWithImpl<$Res>
    implements $BenchTakeCopyWith<$Res> {
  _$BenchTakeCopyWithImpl(this._self, this._then);

  final BenchTake _self;
  final $Res Function(BenchTake) _then;

/// Create a copy of BenchTake
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? n = null,Object? transcript = null,Object? micOnMs = null,Object? firstPartialMs = freezed,Object? finalMs = freezed,}) {
  return _then(BenchTake(
n: null == n ? _self.n : n // ignore: cast_nullable_to_non_nullable
as int,transcript: null == transcript ? _self.transcript : transcript // ignore: cast_nullable_to_non_nullable
as String,micOnMs: null == micOnMs ? _self.micOnMs : micOnMs // ignore: cast_nullable_to_non_nullable
as int,firstPartialMs: freezed == firstPartialMs ? _self.firstPartialMs : firstPartialMs // ignore: cast_nullable_to_non_nullable
as int?,finalMs: freezed == finalMs ? _self.finalMs : finalMs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [BenchTake].
extension BenchTakePatterns on BenchTake {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BenchTake value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BenchTake() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BenchTake value)  $default,){
final _that = this;
switch (_that) {
case _BenchTake():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BenchTake value)?  $default,){
final _that = this;
switch (_that) {
case _BenchTake() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int n,  String transcript,  int micOnMs,  int? firstPartialMs,  int? finalMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BenchTake() when $default != null:
return $default(_that.n,_that.transcript,_that.micOnMs,_that.firstPartialMs,_that.finalMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int n,  String transcript,  int micOnMs,  int? firstPartialMs,  int? finalMs)  $default,) {final _that = this;
switch (_that) {
case _BenchTake():
return $default(_that.n,_that.transcript,_that.micOnMs,_that.firstPartialMs,_that.finalMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int n,  String transcript,  int micOnMs,  int? firstPartialMs,  int? finalMs)?  $default,) {final _that = this;
switch (_that) {
case _BenchTake() when $default != null:
return $default(_that.n,_that.transcript,_that.micOnMs,_that.firstPartialMs,_that.finalMs);case _:
  return null;

}
}

}

/// @nodoc


class _BenchTake implements BenchTake {
  const _BenchTake({required this.n, required this.transcript, required this.micOnMs, this.firstPartialMs, this.finalMs});
  

@override final  int n;
@override final  String transcript;
@override final  int micOnMs;
@override final  int? firstPartialMs;
@override final  int? finalMs;

/// Create a copy of BenchTake
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BenchTakeCopyWith<_BenchTake> get copyWith => __$BenchTakeCopyWithImpl<_BenchTake>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BenchTake&&(identical(other.n, n) || other.n == n)&&(identical(other.transcript, transcript) || other.transcript == transcript)&&(identical(other.micOnMs, micOnMs) || other.micOnMs == micOnMs)&&(identical(other.firstPartialMs, firstPartialMs) || other.firstPartialMs == firstPartialMs)&&(identical(other.finalMs, finalMs) || other.finalMs == finalMs));
}


@override
int get hashCode {
    return Object.hash(runtimeType,n,transcript,micOnMs,firstPartialMs,finalMs);
}

@override
String toString() {
    return 'BenchTake(n: $n, transcript: $transcript, micOnMs: $micOnMs, firstPartialMs: $firstPartialMs, finalMs: $finalMs)';
}


}

/// @nodoc
abstract mixin class _$BenchTakeCopyWith<$Res> implements $BenchTakeCopyWith<$Res> {
  factory _$BenchTakeCopyWith(_BenchTake value, $Res Function(_BenchTake) _then) = __$BenchTakeCopyWithImpl;
@override @useResult
$Res call({
 int n, String transcript, int micOnMs, int? firstPartialMs, int? finalMs
});




}
/// @nodoc
class __$BenchTakeCopyWithImpl<$Res>
    implements _$BenchTakeCopyWith<$Res> {
  __$BenchTakeCopyWithImpl(this._self, this._then);

  final _BenchTake _self;
  final $Res Function(_BenchTake) _then;

/// Create a copy of BenchTake
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? n = null,Object? transcript = null,Object? micOnMs = null,Object? firstPartialMs = freezed,Object? finalMs = freezed,}) {
  return _then(_BenchTake(
n: null == n ? _self.n : n // ignore: cast_nullable_to_non_nullable
as int,transcript: null == transcript ? _self.transcript : transcript // ignore: cast_nullable_to_non_nullable
as String,micOnMs: null == micOnMs ? _self.micOnMs : micOnMs // ignore: cast_nullable_to_non_nullable
as int,firstPartialMs: freezed == firstPartialMs ? _self.firstPartialMs : firstPartialMs // ignore: cast_nullable_to_non_nullable
as int?,finalMs: freezed == finalMs ? _self.finalMs : finalMs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
