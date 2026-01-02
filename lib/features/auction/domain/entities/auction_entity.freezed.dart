// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auction_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AuctionEntity {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String? get imageBase64 => throw _privateConstructorUsedError;
  double get startPrice => throw _privateConstructorUsedError;
  double get currentPrice => throw _privateConstructorUsedError;
  double? get buyoutPrice => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  String get sellerId => throw _privateConstructorUsedError;
  int get bidCount => throw _privateConstructorUsedError;
  String? get lastBidderId => throw _privateConstructorUsedError;
  String? get winnerId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DeliveryInfo? get deliveryInfo => throw _privateConstructorUsedError;

  /// Create a copy of AuctionEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuctionEntityCopyWith<AuctionEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuctionEntityCopyWith<$Res> {
  factory $AuctionEntityCopyWith(
          AuctionEntity value, $Res Function(AuctionEntity) then) =
      _$AuctionEntityCopyWithImpl<$Res, AuctionEntity>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String imageUrl,
      String? imageBase64,
      double startPrice,
      double currentPrice,
      double? buyoutPrice,
      DateTime endDate,
      String sellerId,
      int bidCount,
      String? lastBidderId,
      String? winnerId,
      String status,
      DeliveryInfo? deliveryInfo});
}

/// @nodoc
class _$AuctionEntityCopyWithImpl<$Res, $Val extends AuctionEntity>
    implements $AuctionEntityCopyWith<$Res> {
  _$AuctionEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuctionEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? imageUrl = null,
    Object? imageBase64 = freezed,
    Object? startPrice = null,
    Object? currentPrice = null,
    Object? buyoutPrice = freezed,
    Object? endDate = null,
    Object? sellerId = null,
    Object? bidCount = null,
    Object? lastBidderId = freezed,
    Object? winnerId = freezed,
    Object? status = null,
    Object? deliveryInfo = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      imageBase64: freezed == imageBase64
          ? _value.imageBase64
          : imageBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      startPrice: null == startPrice
          ? _value.startPrice
          : startPrice // ignore: cast_nullable_to_non_nullable
              as double,
      currentPrice: null == currentPrice
          ? _value.currentPrice
          : currentPrice // ignore: cast_nullable_to_non_nullable
              as double,
      buyoutPrice: freezed == buyoutPrice
          ? _value.buyoutPrice
          : buyoutPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sellerId: null == sellerId
          ? _value.sellerId
          : sellerId // ignore: cast_nullable_to_non_nullable
              as String,
      bidCount: null == bidCount
          ? _value.bidCount
          : bidCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastBidderId: freezed == lastBidderId
          ? _value.lastBidderId
          : lastBidderId // ignore: cast_nullable_to_non_nullable
              as String?,
      winnerId: freezed == winnerId
          ? _value.winnerId
          : winnerId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      deliveryInfo: freezed == deliveryInfo
          ? _value.deliveryInfo
          : deliveryInfo // ignore: cast_nullable_to_non_nullable
              as DeliveryInfo?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuctionEntityImplCopyWith<$Res>
    implements $AuctionEntityCopyWith<$Res> {
  factory _$$AuctionEntityImplCopyWith(
          _$AuctionEntityImpl value, $Res Function(_$AuctionEntityImpl) then) =
      __$$AuctionEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String imageUrl,
      String? imageBase64,
      double startPrice,
      double currentPrice,
      double? buyoutPrice,
      DateTime endDate,
      String sellerId,
      int bidCount,
      String? lastBidderId,
      String? winnerId,
      String status,
      DeliveryInfo? deliveryInfo});
}

/// @nodoc
class __$$AuctionEntityImplCopyWithImpl<$Res>
    extends _$AuctionEntityCopyWithImpl<$Res, _$AuctionEntityImpl>
    implements _$$AuctionEntityImplCopyWith<$Res> {
  __$$AuctionEntityImplCopyWithImpl(
      _$AuctionEntityImpl _value, $Res Function(_$AuctionEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuctionEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? imageUrl = null,
    Object? imageBase64 = freezed,
    Object? startPrice = null,
    Object? currentPrice = null,
    Object? buyoutPrice = freezed,
    Object? endDate = null,
    Object? sellerId = null,
    Object? bidCount = null,
    Object? lastBidderId = freezed,
    Object? winnerId = freezed,
    Object? status = null,
    Object? deliveryInfo = freezed,
  }) {
    return _then(_$AuctionEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      imageBase64: freezed == imageBase64
          ? _value.imageBase64
          : imageBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      startPrice: null == startPrice
          ? _value.startPrice
          : startPrice // ignore: cast_nullable_to_non_nullable
              as double,
      currentPrice: null == currentPrice
          ? _value.currentPrice
          : currentPrice // ignore: cast_nullable_to_non_nullable
              as double,
      buyoutPrice: freezed == buyoutPrice
          ? _value.buyoutPrice
          : buyoutPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sellerId: null == sellerId
          ? _value.sellerId
          : sellerId // ignore: cast_nullable_to_non_nullable
              as String,
      bidCount: null == bidCount
          ? _value.bidCount
          : bidCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastBidderId: freezed == lastBidderId
          ? _value.lastBidderId
          : lastBidderId // ignore: cast_nullable_to_non_nullable
              as String?,
      winnerId: freezed == winnerId
          ? _value.winnerId
          : winnerId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      deliveryInfo: freezed == deliveryInfo
          ? _value.deliveryInfo
          : deliveryInfo // ignore: cast_nullable_to_non_nullable
              as DeliveryInfo?,
    ));
  }
}

/// @nodoc

class _$AuctionEntityImpl extends _AuctionEntity {
  const _$AuctionEntityImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.imageUrl,
      this.imageBase64,
      required this.startPrice,
      required this.currentPrice,
      this.buyoutPrice,
      required this.endDate,
      required this.sellerId,
      this.bidCount = 0,
      this.lastBidderId,
      this.winnerId,
      this.status = 'active',
      this.deliveryInfo})
      : super._();

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String imageUrl;
  @override
  final String? imageBase64;
  @override
  final double startPrice;
  @override
  final double currentPrice;
  @override
  final double? buyoutPrice;
  @override
  final DateTime endDate;
  @override
  final String sellerId;
  @override
  @JsonKey()
  final int bidCount;
  @override
  final String? lastBidderId;
  @override
  final String? winnerId;
  @override
  @JsonKey()
  final String status;
  @override
  final DeliveryInfo? deliveryInfo;

  @override
  String toString() {
    return 'AuctionEntity(id: $id, title: $title, description: $description, imageUrl: $imageUrl, imageBase64: $imageBase64, startPrice: $startPrice, currentPrice: $currentPrice, buyoutPrice: $buyoutPrice, endDate: $endDate, sellerId: $sellerId, bidCount: $bidCount, lastBidderId: $lastBidderId, winnerId: $winnerId, status: $status, deliveryInfo: $deliveryInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuctionEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.imageBase64, imageBase64) ||
                other.imageBase64 == imageBase64) &&
            (identical(other.startPrice, startPrice) ||
                other.startPrice == startPrice) &&
            (identical(other.currentPrice, currentPrice) ||
                other.currentPrice == currentPrice) &&
            (identical(other.buyoutPrice, buyoutPrice) ||
                other.buyoutPrice == buyoutPrice) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.sellerId, sellerId) ||
                other.sellerId == sellerId) &&
            (identical(other.bidCount, bidCount) ||
                other.bidCount == bidCount) &&
            (identical(other.lastBidderId, lastBidderId) ||
                other.lastBidderId == lastBidderId) &&
            (identical(other.winnerId, winnerId) ||
                other.winnerId == winnerId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.deliveryInfo, deliveryInfo) ||
                other.deliveryInfo == deliveryInfo));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      imageUrl,
      imageBase64,
      startPrice,
      currentPrice,
      buyoutPrice,
      endDate,
      sellerId,
      bidCount,
      lastBidderId,
      winnerId,
      status,
      deliveryInfo);

  /// Create a copy of AuctionEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuctionEntityImplCopyWith<_$AuctionEntityImpl> get copyWith =>
      __$$AuctionEntityImplCopyWithImpl<_$AuctionEntityImpl>(this, _$identity);
}

abstract class _AuctionEntity extends AuctionEntity {
  const factory _AuctionEntity(
      {required final String id,
      required final String title,
      required final String description,
      required final String imageUrl,
      final String? imageBase64,
      required final double startPrice,
      required final double currentPrice,
      final double? buyoutPrice,
      required final DateTime endDate,
      required final String sellerId,
      final int bidCount,
      final String? lastBidderId,
      final String? winnerId,
      final String status,
      final DeliveryInfo? deliveryInfo}) = _$AuctionEntityImpl;
  const _AuctionEntity._() : super._();

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get imageUrl;
  @override
  String? get imageBase64;
  @override
  double get startPrice;
  @override
  double get currentPrice;
  @override
  double? get buyoutPrice;
  @override
  DateTime get endDate;
  @override
  String get sellerId;
  @override
  int get bidCount;
  @override
  String? get lastBidderId;
  @override
  String? get winnerId;
  @override
  String get status;
  @override
  DeliveryInfo? get deliveryInfo;

  /// Create a copy of AuctionEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuctionEntityImplCopyWith<_$AuctionEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
