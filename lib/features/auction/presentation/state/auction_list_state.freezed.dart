// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auction_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuctionListState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuctionListState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuctionListState()';
}


}

/// @nodoc
class $AuctionListStateCopyWith<$Res>  {
$AuctionListStateCopyWith(AuctionListState _, $Res Function(AuctionListState) __);
}


/// Adds pattern-matching-related methods to [AuctionListState].
extension AuctionListStatePatterns on AuctionListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AuctionListInitial value)?  initial,TResult Function( AuctionListLoading value)?  loading,TResult Function( AuctionListSuccess value)?  success,TResult Function( AuctionListError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AuctionListInitial() when initial != null:
return initial(_that);case AuctionListLoading() when loading != null:
return loading(_that);case AuctionListSuccess() when success != null:
return success(_that);case AuctionListError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AuctionListInitial value)  initial,required TResult Function( AuctionListLoading value)  loading,required TResult Function( AuctionListSuccess value)  success,required TResult Function( AuctionListError value)  error,}){
final _that = this;
switch (_that) {
case AuctionListInitial():
return initial(_that);case AuctionListLoading():
return loading(_that);case AuctionListSuccess():
return success(_that);case AuctionListError():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AuctionListInitial value)?  initial,TResult? Function( AuctionListLoading value)?  loading,TResult? Function( AuctionListSuccess value)?  success,TResult? Function( AuctionListError value)?  error,}){
final _that = this;
switch (_that) {
case AuctionListInitial() when initial != null:
return initial(_that);case AuctionListLoading() when loading != null:
return loading(_that);case AuctionListSuccess() when success != null:
return success(_that);case AuctionListError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<AuctionEntity> items,  bool hasMore,  bool isFetchingMore)?  success,TResult Function( Object error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AuctionListInitial() when initial != null:
return initial();case AuctionListLoading() when loading != null:
return loading();case AuctionListSuccess() when success != null:
return success(_that.items,_that.hasMore,_that.isFetchingMore);case AuctionListError() when error != null:
return error(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<AuctionEntity> items,  bool hasMore,  bool isFetchingMore)  success,required TResult Function( Object error)  error,}) {final _that = this;
switch (_that) {
case AuctionListInitial():
return initial();case AuctionListLoading():
return loading();case AuctionListSuccess():
return success(_that.items,_that.hasMore,_that.isFetchingMore);case AuctionListError():
return error(_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<AuctionEntity> items,  bool hasMore,  bool isFetchingMore)?  success,TResult? Function( Object error)?  error,}) {final _that = this;
switch (_that) {
case AuctionListInitial() when initial != null:
return initial();case AuctionListLoading() when loading != null:
return loading();case AuctionListSuccess() when success != null:
return success(_that.items,_that.hasMore,_that.isFetchingMore);case AuctionListError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class AuctionListInitial implements AuctionListState {
  const AuctionListInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuctionListInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuctionListState.initial()';
}


}




/// @nodoc


class AuctionListLoading implements AuctionListState {
  const AuctionListLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuctionListLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuctionListState.loading()';
}


}




/// @nodoc


class AuctionListSuccess implements AuctionListState {
  const AuctionListSuccess({required final  List<AuctionEntity> items, required this.hasMore, this.isFetchingMore = false}): _items = items;
  

 final  List<AuctionEntity> _items;
 List<AuctionEntity> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  bool hasMore;
@JsonKey() final  bool isFetchingMore;

/// Create a copy of AuctionListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuctionListSuccessCopyWith<AuctionListSuccess> get copyWith => _$AuctionListSuccessCopyWithImpl<AuctionListSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuctionListSuccess&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.isFetchingMore, isFetchingMore) || other.isFetchingMore == isFetchingMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),hasMore,isFetchingMore);

@override
String toString() {
  return 'AuctionListState.success(items: $items, hasMore: $hasMore, isFetchingMore: $isFetchingMore)';
}


}

/// @nodoc
abstract mixin class $AuctionListSuccessCopyWith<$Res> implements $AuctionListStateCopyWith<$Res> {
  factory $AuctionListSuccessCopyWith(AuctionListSuccess value, $Res Function(AuctionListSuccess) _then) = _$AuctionListSuccessCopyWithImpl;
@useResult
$Res call({
 List<AuctionEntity> items, bool hasMore, bool isFetchingMore
});




}
/// @nodoc
class _$AuctionListSuccessCopyWithImpl<$Res>
    implements $AuctionListSuccessCopyWith<$Res> {
  _$AuctionListSuccessCopyWithImpl(this._self, this._then);

  final AuctionListSuccess _self;
  final $Res Function(AuctionListSuccess) _then;

/// Create a copy of AuctionListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? items = null,Object? hasMore = null,Object? isFetchingMore = null,}) {
  return _then(AuctionListSuccess(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<AuctionEntity>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isFetchingMore: null == isFetchingMore ? _self.isFetchingMore : isFetchingMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class AuctionListError implements AuctionListState {
  const AuctionListError({required this.error});
  

 final  Object error;

/// Create a copy of AuctionListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuctionListErrorCopyWith<AuctionListError> get copyWith => _$AuctionListErrorCopyWithImpl<AuctionListError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuctionListError&&const DeepCollectionEquality().equals(other.error, error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(error));

@override
String toString() {
  return 'AuctionListState.error(error: $error)';
}


}

/// @nodoc
abstract mixin class $AuctionListErrorCopyWith<$Res> implements $AuctionListStateCopyWith<$Res> {
  factory $AuctionListErrorCopyWith(AuctionListError value, $Res Function(AuctionListError) _then) = _$AuctionListErrorCopyWithImpl;
@useResult
$Res call({
 Object error
});




}
/// @nodoc
class _$AuctionListErrorCopyWithImpl<$Res>
    implements $AuctionListErrorCopyWith<$Res> {
  _$AuctionListErrorCopyWithImpl(this._self, this._then);

  final AuctionListError _self;
  final $Res Function(AuctionListError) _then;

/// Create a copy of AuctionListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(AuctionListError(
error: null == error ? _self.error : error ,
  ));
}


}

// dart format on
