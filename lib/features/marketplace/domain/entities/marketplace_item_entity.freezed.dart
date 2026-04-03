// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marketplace_item_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MarketplaceItemEntity {

 String get id; String get title; String get description; String get imageUrl; String? get imageBase64; String get category; String get currency; double get price; String get sellerId; String? get winnerId; String get status; DeliveryInfo? get deliveryInfo; DateTime? get createdAt;
/// Create a copy of MarketplaceItemEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketplaceItemEntityCopyWith<MarketplaceItemEntity> get copyWith => _$MarketplaceItemEntityCopyWithImpl<MarketplaceItemEntity>(this as MarketplaceItemEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MarketplaceItemEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.imageBase64, imageBase64) || other.imageBase64 == imageBase64)&&(identical(other.category, category) || other.category == category)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.price, price) || other.price == price)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.status, status) || other.status == status)&&(identical(other.deliveryInfo, deliveryInfo) || other.deliveryInfo == deliveryInfo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,imageUrl,imageBase64,category,currency,price,sellerId,winnerId,status,deliveryInfo,createdAt);

@override
String toString() {
  return 'MarketplaceItemEntity(id: $id, title: $title, description: $description, imageUrl: $imageUrl, imageBase64: $imageBase64, category: $category, currency: $currency, price: $price, sellerId: $sellerId, winnerId: $winnerId, status: $status, deliveryInfo: $deliveryInfo, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MarketplaceItemEntityCopyWith<$Res>  {
  factory $MarketplaceItemEntityCopyWith(MarketplaceItemEntity value, $Res Function(MarketplaceItemEntity) _then) = _$MarketplaceItemEntityCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String imageUrl, String? imageBase64, String category, String currency, double price, String sellerId, String? winnerId, String status, DeliveryInfo? deliveryInfo, DateTime? createdAt
});




}
/// @nodoc
class _$MarketplaceItemEntityCopyWithImpl<$Res>
    implements $MarketplaceItemEntityCopyWith<$Res> {
  _$MarketplaceItemEntityCopyWithImpl(this._self, this._then);

  final MarketplaceItemEntity _self;
  final $Res Function(MarketplaceItemEntity) _then;

/// Create a copy of MarketplaceItemEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? imageUrl = null,Object? imageBase64 = freezed,Object? category = null,Object? currency = null,Object? price = null,Object? sellerId = null,Object? winnerId = freezed,Object? status = null,Object? deliveryInfo = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,imageBase64: freezed == imageBase64 ? _self.imageBase64 : imageBase64 // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,deliveryInfo: freezed == deliveryInfo ? _self.deliveryInfo : deliveryInfo // ignore: cast_nullable_to_non_nullable
as DeliveryInfo?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MarketplaceItemEntity].
extension MarketplaceItemEntityPatterns on MarketplaceItemEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MarketplaceItemEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MarketplaceItemEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MarketplaceItemEntity value)  $default,){
final _that = this;
switch (_that) {
case _MarketplaceItemEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MarketplaceItemEntity value)?  $default,){
final _that = this;
switch (_that) {
case _MarketplaceItemEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String imageUrl,  String? imageBase64,  String category,  String currency,  double price,  String sellerId,  String? winnerId,  String status,  DeliveryInfo? deliveryInfo,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MarketplaceItemEntity() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.imageUrl,_that.imageBase64,_that.category,_that.currency,_that.price,_that.sellerId,_that.winnerId,_that.status,_that.deliveryInfo,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String imageUrl,  String? imageBase64,  String category,  String currency,  double price,  String sellerId,  String? winnerId,  String status,  DeliveryInfo? deliveryInfo,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _MarketplaceItemEntity():
return $default(_that.id,_that.title,_that.description,_that.imageUrl,_that.imageBase64,_that.category,_that.currency,_that.price,_that.sellerId,_that.winnerId,_that.status,_that.deliveryInfo,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String imageUrl,  String? imageBase64,  String category,  String currency,  double price,  String sellerId,  String? winnerId,  String status,  DeliveryInfo? deliveryInfo,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MarketplaceItemEntity() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.imageUrl,_that.imageBase64,_that.category,_that.currency,_that.price,_that.sellerId,_that.winnerId,_that.status,_that.deliveryInfo,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _MarketplaceItemEntity extends MarketplaceItemEntity {
  const _MarketplaceItemEntity({required this.id, required this.title, required this.description, required this.imageUrl, this.imageBase64, this.category = '', this.currency = 'UAH', required this.price, required this.sellerId, this.winnerId, this.status = 'active', this.deliveryInfo, this.createdAt}): super._();
  

@override final  String id;
@override final  String title;
@override final  String description;
@override final  String imageUrl;
@override final  String? imageBase64;
@override@JsonKey() final  String category;
@override@JsonKey() final  String currency;
@override final  double price;
@override final  String sellerId;
@override final  String? winnerId;
@override@JsonKey() final  String status;
@override final  DeliveryInfo? deliveryInfo;
@override final  DateTime? createdAt;

/// Create a copy of MarketplaceItemEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarketplaceItemEntityCopyWith<_MarketplaceItemEntity> get copyWith => __$MarketplaceItemEntityCopyWithImpl<_MarketplaceItemEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MarketplaceItemEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.imageBase64, imageBase64) || other.imageBase64 == imageBase64)&&(identical(other.category, category) || other.category == category)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.price, price) || other.price == price)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.status, status) || other.status == status)&&(identical(other.deliveryInfo, deliveryInfo) || other.deliveryInfo == deliveryInfo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,imageUrl,imageBase64,category,currency,price,sellerId,winnerId,status,deliveryInfo,createdAt);

@override
String toString() {
  return 'MarketplaceItemEntity(id: $id, title: $title, description: $description, imageUrl: $imageUrl, imageBase64: $imageBase64, category: $category, currency: $currency, price: $price, sellerId: $sellerId, winnerId: $winnerId, status: $status, deliveryInfo: $deliveryInfo, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MarketplaceItemEntityCopyWith<$Res> implements $MarketplaceItemEntityCopyWith<$Res> {
  factory _$MarketplaceItemEntityCopyWith(_MarketplaceItemEntity value, $Res Function(_MarketplaceItemEntity) _then) = __$MarketplaceItemEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String imageUrl, String? imageBase64, String category, String currency, double price, String sellerId, String? winnerId, String status, DeliveryInfo? deliveryInfo, DateTime? createdAt
});




}
/// @nodoc
class __$MarketplaceItemEntityCopyWithImpl<$Res>
    implements _$MarketplaceItemEntityCopyWith<$Res> {
  __$MarketplaceItemEntityCopyWithImpl(this._self, this._then);

  final _MarketplaceItemEntity _self;
  final $Res Function(_MarketplaceItemEntity) _then;

/// Create a copy of MarketplaceItemEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? imageUrl = null,Object? imageBase64 = freezed,Object? category = null,Object? currency = null,Object? price = null,Object? sellerId = null,Object? winnerId = freezed,Object? status = null,Object? deliveryInfo = freezed,Object? createdAt = freezed,}) {
  return _then(_MarketplaceItemEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,imageBase64: freezed == imageBase64 ? _self.imageBase64 : imageBase64 // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,deliveryInfo: freezed == deliveryInfo ? _self.deliveryInfo : deliveryInfo // ignore: cast_nullable_to_non_nullable
as DeliveryInfo?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
