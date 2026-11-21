// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReviewState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ReviewState()';
}


}

/// @nodoc
class $ReviewStateCopyWith<$Res>  {
$ReviewStateCopyWith(ReviewState _, $Res Function(ReviewState) __);
}


/// Adds pattern-matching-related methods to [ReviewState].
extension ReviewStatePatterns on ReviewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ReviewLoading value)?  loading,TResult Function( ReviewNoCase value)?  noCase,TResult Function( ReviewReady value)?  ready,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ReviewLoading() when loading != null:
return loading(_that);case ReviewNoCase() when noCase != null:
return noCase(_that);case ReviewReady() when ready != null:
return ready(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ReviewLoading value)  loading,required TResult Function( ReviewNoCase value)  noCase,required TResult Function( ReviewReady value)  ready,}){
final _that = this;
switch (_that) {
case ReviewLoading():
return loading(_that);case ReviewNoCase():
return noCase(_that);case ReviewReady():
return ready(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ReviewLoading value)?  loading,TResult? Function( ReviewNoCase value)?  noCase,TResult? Function( ReviewReady value)?  ready,}){
final _that = this;
switch (_that) {
case ReviewLoading() when loading != null:
return loading(_that);case ReviewNoCase() when noCase != null:
return noCase(_that);case ReviewReady() when ready != null:
return ready(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function()?  noCase,TResult Function( IntakeCase intakeCase,  String draft,  bool approving,  Failure? approveFailure)?  ready,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ReviewLoading() when loading != null:
return loading();case ReviewNoCase() when noCase != null:
return noCase();case ReviewReady() when ready != null:
return ready(_that.intakeCase,_that.draft,_that.approving,_that.approveFailure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function()  noCase,required TResult Function( IntakeCase intakeCase,  String draft,  bool approving,  Failure? approveFailure)  ready,}) {final _that = this;
switch (_that) {
case ReviewLoading():
return loading();case ReviewNoCase():
return noCase();case ReviewReady():
return ready(_that.intakeCase,_that.draft,_that.approving,_that.approveFailure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function()?  noCase,TResult? Function( IntakeCase intakeCase,  String draft,  bool approving,  Failure? approveFailure)?  ready,}) {final _that = this;
switch (_that) {
case ReviewLoading() when loading != null:
return loading();case ReviewNoCase() when noCase != null:
return noCase();case ReviewReady() when ready != null:
return ready(_that.intakeCase,_that.draft,_that.approving,_that.approveFailure);case _:
  return null;

}
}

}

/// @nodoc


class ReviewLoading implements ReviewState {
  const ReviewLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ReviewState.loading()';
}


}




/// @nodoc


class ReviewNoCase implements ReviewState {
  const ReviewNoCase();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewNoCase);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ReviewState.noCase()';
}


}




/// @nodoc


class ReviewReady implements ReviewState {
  const ReviewReady({required this.intakeCase, required this.draft, this.approving = false, this.approveFailure});
  

 final  IntakeCase intakeCase;
 final  String draft;
@JsonKey() final  bool approving;
 final  Failure? approveFailure;

/// Create a copy of ReviewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewReadyCopyWith<ReviewReady> get copyWith => _$ReviewReadyCopyWithImpl<ReviewReady>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewReady&&(identical(other.intakeCase, intakeCase) || other.intakeCase == intakeCase)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.approving, approving) || other.approving == approving)&&(identical(other.approveFailure, approveFailure) || other.approveFailure == approveFailure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,intakeCase,draft,approving,approveFailure);
}

@override
String toString() {
    return 'ReviewState.ready(intakeCase: $intakeCase, draft: $draft, approving: $approving, approveFailure: $approveFailure)';
}


}

/// @nodoc
abstract mixin class $ReviewReadyCopyWith<$Res> implements $ReviewStateCopyWith<$Res> {
  factory $ReviewReadyCopyWith(ReviewReady value, $Res Function(ReviewReady) _then) = _$ReviewReadyCopyWithImpl;
@useResult
$Res call({
 IntakeCase intakeCase, String draft, bool approving, Failure? approveFailure
});


$IntakeCaseCopyWith<$Res> get intakeCase;

}
/// @nodoc
class _$ReviewReadyCopyWithImpl<$Res>
    implements $ReviewReadyCopyWith<$Res> {
  _$ReviewReadyCopyWithImpl(this._self, this._then);

  final ReviewReady _self;
  final $Res Function(ReviewReady) _then;

/// Create a copy of ReviewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? intakeCase = null,Object? draft = null,Object? approving = null,Object? approveFailure = freezed,}) {
  return _then(ReviewReady(
intakeCase: null == intakeCase ? _self.intakeCase : intakeCase // ignore: cast_nullable_to_non_nullable
as IntakeCase,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as String,approving: null == approving ? _self.approving : approving // ignore: cast_nullable_to_non_nullable
as bool,approveFailure: freezed == approveFailure ? _self.approveFailure : approveFailure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

/// Create a copy of ReviewState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IntakeCaseCopyWith<$Res> get intakeCase {
  
  return $IntakeCaseCopyWith<$Res>(_self.intakeCase, (value) {
    return _then(_self.copyWith(intakeCase: value));
  });
}
}

// dart format on
