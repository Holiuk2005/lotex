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
  double get startPrice;
  double get currentPrice;
  DateTime get endDate;
  String get sellerId;
  int get bidCount;

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
            (identical(other.startPrice, startPrice) ||
                other.startPrice == startPrice) &&
            (identical(other.currentPrice, currentPrice) ||
                other.currentPrice == currentPrice) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.sellerId, sellerId) ||
                other.sellerId == sellerId) &&
            (identical(other.bidCount, bidCount) ||
                other.bidCount == bidCount));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, description, imageUrl,
      startPrice, currentPrice, endDate, sellerId, bidCount);

  @override
  String toString() {
    return 'AuctionEntity(id: $id, title: $title, description: $description, imageUrl: $imageUrl, startPrice: $startPrice, currentPrice: $currentPrice, endDate: $endDate, sellerId: $sellerId, bidCount: $bidCount)';
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
      double startPrice,
      double currentPrice,
      DateTime endDate,
      String sellerId,
      int bidCount});
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
    Object? startPrice = null,
    Object? currentPrice = null,
    Object? endDate = null,
    Object? sellerId = null,
    Object? bidCount = null,
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
      startPrice: null == startPrice
          ? _self.startPrice
          : startPrice // ignore: cast_nullable_to_non_nullable
              as double,
      currentPrice: null == currentPrice
          ? _self.currentPrice
          : currentPrice // ignore: cast_nullable_to_non_nullable
              as double,
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
            double startPrice,
            double currentPrice,
            DateTime endDate,
            String sellerId,
            int bidCount)?
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
            _that.startPrice,
            _that.currentPrice,
            _that.endDate,
            _that.sellerId,
            _that.bidCount);
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
            double startPrice,
            double currentPrice,
            DateTime endDate,
            String sellerId,
            int bidCount)
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
            _that.startPrice,
            _that.currentPrice,
            _that.endDate,
            _that.sellerId,
            _that.bidCount);
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
            double startPrice,
            double currentPrice,
            DateTime endDate,
            String sellerId,
            int bidCount)?
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
            _that.startPrice,
            _that.currentPrice,
            _that.endDate,
            _that.sellerId,
            _that.bidCount);
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
      required this.startPrice,
      required this.currentPrice,
      required this.endDate,
      required this.sellerId,
      this.bidCount = 0})
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
  final double startPrice;
  @override
  final double currentPrice;
  @override
  final DateTime endDate;
  @override
  final String sellerId;
  @override
  @JsonKey()
  final int bidCount;

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
            (identical(other.startPrice, startPrice) ||
                other.startPrice == startPrice) &&
            (identical(other.currentPrice, currentPrice) ||
                other.currentPrice == currentPrice) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.sellerId, sellerId) ||
                other.sellerId == sellerId) &&
            (identical(other.bidCount, bidCount) ||
                other.bidCount == bidCount));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, description, imageUrl,
      startPrice, currentPrice, endDate, sellerId, bidCount);

  @override
  String toString() {
    return 'AuctionEntity(id: $id, title: $title, description: $description, imageUrl: $imageUrl, startPrice: $startPrice, currentPrice: $currentPrice, endDate: $endDate, sellerId: $sellerId, bidCount: $bidCount)';
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
      double startPrice,
      double currentPrice,
      DateTime endDate,
      String sellerId,
      int bidCount});
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
    Object? startPrice = null,
    Object? currentPrice = null,
    Object? endDate = null,
    Object? sellerId = null,
    Object? bidCount = null,
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
      startPrice: null == startPrice
          ? _self.startPrice
          : startPrice // ignore: cast_nullable_to_non_nullable
              as double,
      currentPrice: null == currentPrice
          ? _self.currentPrice
          : currentPrice // ignore: cast_nullable_to_non_nullable
              as double,
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
    ));
  }
}

// dart format on
