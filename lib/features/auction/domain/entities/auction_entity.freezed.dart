// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auction_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuctionEntity {
  String get id;
  String get title;
  String get description;
  String get imageUrl;
  String? get imageBase64;
  double get startPrice;
  double get currentPrice;
  double? get buyoutPrice;
  DateTime get endDate;
  String get sellerId;
  int get bidCount;
  String? get lastBidderId;
  String? get winnerId;
  String get status;
  DeliveryInfo? get deliveryInfo;

  /// Create a copy of AuctionEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AuctionEntityCopyWith<AuctionEntity> get copyWith =>
      _$AuctionEntityCopyWithImpl<AuctionEntity>(
          this as AuctionEntity, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AuctionEntity &&
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

  @override
  String toString() {
    return 'AuctionEntity(id: $id, title: $title, description: $description, imageUrl: $imageUrl, imageBase64: $imageBase64, startPrice: $startPrice, currentPrice: $currentPrice, buyoutPrice: $buyoutPrice, endDate: $endDate, sellerId: $sellerId, bidCount: $bidCount, lastBidderId: $lastBidderId, winnerId: $winnerId, status: $status, deliveryInfo: $deliveryInfo)';
  }
}

/// @nodoc
abstract mixin class $AuctionEntityCopyWith<$Res> {
  factory $AuctionEntityCopyWith(
          AuctionEntity value, $Res Function(AuctionEntity) _then) =
      _$AuctionEntityCopyWithImpl;
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
class _$AuctionEntityCopyWithImpl<$Res>
    implements $AuctionEntityCopyWith<$Res> {
  _$AuctionEntityCopyWithImpl(this._self, this._then);

  final AuctionEntity _self;
  final $Res Function(AuctionEntity) _then;

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
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      imageBase64: freezed == imageBase64
          ? _self.imageBase64
          : imageBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      startPrice: null == startPrice
          ? _self.startPrice
          : startPrice // ignore: cast_nullable_to_non_nullable
              as double,
      currentPrice: null == currentPrice
          ? _self.currentPrice
          : currentPrice // ignore: cast_nullable_to_non_nullable
              as double,
      buyoutPrice: freezed == buyoutPrice
          ? _self.buyoutPrice
          : buyoutPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      endDate: null == endDate
          ? _self.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sellerId: null == sellerId
          ? _self.sellerId
          : sellerId // ignore: cast_nullable_to_non_nullable
              as String,
      bidCount: null == bidCount
          ? _self.bidCount
          : bidCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastBidderId: freezed == lastBidderId
          ? _self.lastBidderId
          : lastBidderId // ignore: cast_nullable_to_non_nullable
              as String?,
      winnerId: freezed == winnerId
          ? _self.winnerId
          : winnerId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      deliveryInfo: freezed == deliveryInfo
          ? _self.deliveryInfo
          : deliveryInfo // ignore: cast_nullable_to_non_nullable
              as DeliveryInfo?,
    ));
  }
}

/// Adds pattern-matching-related methods to [AuctionEntity].
extension AuctionEntityPatterns on AuctionEntity {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AuctionEntity value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AuctionEntity() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_AuctionEntity value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuctionEntity():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AuctionEntity value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuctionEntity() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
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
            DeliveryInfo? deliveryInfo)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AuctionEntity() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.description,
            _that.imageUrl,
            _that.imageBase64,
            _that.startPrice,
            _that.currentPrice,
            _that.buyoutPrice,
            _that.endDate,
            _that.sellerId,
            _that.bidCount,
            _that.lastBidderId,
            _that.winnerId,
            _that.status,
            _that.deliveryInfo);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
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
            DeliveryInfo? deliveryInfo)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuctionEntity():
        return $default(
            _that.id,
            _that.title,
            _that.description,
            _that.imageUrl,
            _that.imageBase64,
            _that.startPrice,
            _that.currentPrice,
            _that.buyoutPrice,
            _that.endDate,
            _that.sellerId,
            _that.bidCount,
            _that.lastBidderId,
            _that.winnerId,
            _that.status,
            _that.deliveryInfo);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
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
            DeliveryInfo? deliveryInfo)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AuctionEntity() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.description,
            _that.imageUrl,
            _that.imageBase64,
            _that.startPrice,
            _that.currentPrice,
            _that.buyoutPrice,
            _that.endDate,
            _that.sellerId,
            _that.bidCount,
            _that.lastBidderId,
            _that.winnerId,
            _that.status,
            _that.deliveryInfo);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AuctionEntity extends AuctionEntity {
  const _AuctionEntity(
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

  /// Create a copy of AuctionEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AuctionEntityCopyWith<_AuctionEntity> get copyWith =>
      __$AuctionEntityCopyWithImpl<_AuctionEntity>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AuctionEntity &&
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

  @override
  String toString() {
    return 'AuctionEntity(id: $id, title: $title, description: $description, imageUrl: $imageUrl, imageBase64: $imageBase64, startPrice: $startPrice, currentPrice: $currentPrice, buyoutPrice: $buyoutPrice, endDate: $endDate, sellerId: $sellerId, bidCount: $bidCount, lastBidderId: $lastBidderId, winnerId: $winnerId, status: $status, deliveryInfo: $deliveryInfo)';
  }
}

/// @nodoc
abstract mixin class _$AuctionEntityCopyWith<$Res>
    implements $AuctionEntityCopyWith<$Res> {
  factory _$AuctionEntityCopyWith(
          _AuctionEntity value, $Res Function(_AuctionEntity) _then) =
      __$AuctionEntityCopyWithImpl;
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
class __$AuctionEntityCopyWithImpl<$Res>
    implements _$AuctionEntityCopyWith<$Res> {
  __$AuctionEntityCopyWithImpl(this._self, this._then);

  final _AuctionEntity _self;
  final $Res Function(_AuctionEntity) _then;

  /// Create a copy of AuctionEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_AuctionEntity(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      imageBase64: freezed == imageBase64
          ? _self.imageBase64
          : imageBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
      startPrice: null == startPrice
          ? _self.startPrice
          : startPrice // ignore: cast_nullable_to_non_nullable
              as double,
      currentPrice: null == currentPrice
          ? _self.currentPrice
          : currentPrice // ignore: cast_nullable_to_non_nullable
              as double,
      buyoutPrice: freezed == buyoutPrice
          ? _self.buyoutPrice
          : buyoutPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      endDate: null == endDate
          ? _self.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sellerId: null == sellerId
          ? _self.sellerId
          : sellerId // ignore: cast_nullable_to_non_nullable
              as String,
      bidCount: null == bidCount
          ? _self.bidCount
          : bidCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastBidderId: freezed == lastBidderId
          ? _self.lastBidderId
          : lastBidderId // ignore: cast_nullable_to_non_nullable
              as String?,
      winnerId: freezed == winnerId
          ? _self.winnerId
          : winnerId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      deliveryInfo: freezed == deliveryInfo
          ? _self.deliveryInfo
          : deliveryInfo // ignore: cast_nullable_to_non_nullable
              as DeliveryInfo?,
    ));
  }
}

// dart format on
