// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_method_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaymentMethodEntity {

 String get id; String get provider; String get type; String get brand; String get last4; int get expMonth; int get expYear; bool get isDefault; String? get wallet;
/// Create a copy of PaymentMethodEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentMethodEntityCopyWith<PaymentMethodEntity> get copyWith => _$PaymentMethodEntityCopyWithImpl<PaymentMethodEntity>(this as PaymentMethodEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentMethodEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.type, type) || other.type == type)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.last4, last4) || other.last4 == last4)&&(identical(other.expMonth, expMonth) || other.expMonth == expMonth)&&(identical(other.expYear, expYear) || other.expYear == expYear)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.wallet, wallet) || other.wallet == wallet));
}


@override
int get hashCode => Object.hash(runtimeType,id,provider,type,brand,last4,expMonth,expYear,isDefault,wallet);

@override
String toString() {
  return 'PaymentMethodEntity(id: $id, provider: $provider, type: $type, brand: $brand, last4: $last4, expMonth: $expMonth, expYear: $expYear, isDefault: $isDefault, wallet: $wallet)';
}


}

/// @nodoc
abstract mixin class $PaymentMethodEntityCopyWith<$Res>  {
  factory $PaymentMethodEntityCopyWith(PaymentMethodEntity value, $Res Function(PaymentMethodEntity) _then) = _$PaymentMethodEntityCopyWithImpl;
@useResult
$Res call({
 String id, String provider, String type, String brand, String last4, int expMonth, int expYear, bool isDefault, String? wallet
});




}
/// @nodoc
class _$PaymentMethodEntityCopyWithImpl<$Res>
    implements $PaymentMethodEntityCopyWith<$Res> {
  _$PaymentMethodEntityCopyWithImpl(this._self, this._then);

  final PaymentMethodEntity _self;
  final $Res Function(PaymentMethodEntity) _then;

/// Create a copy of PaymentMethodEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? provider = null,Object? type = null,Object? brand = null,Object? last4 = null,Object? expMonth = null,Object? expYear = null,Object? isDefault = null,Object? wallet = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,last4: null == last4 ? _self.last4 : last4 // ignore: cast_nullable_to_non_nullable
as String,expMonth: null == expMonth ? _self.expMonth : expMonth // ignore: cast_nullable_to_non_nullable
as int,expYear: null == expYear ? _self.expYear : expYear // ignore: cast_nullable_to_non_nullable
as int,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,wallet: freezed == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentMethodEntity].
extension PaymentMethodEntityPatterns on PaymentMethodEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentMethodEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentMethodEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentMethodEntity value)  $default,){
final _that = this;
switch (_that) {
case _PaymentMethodEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentMethodEntity value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentMethodEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String provider,  String type,  String brand,  String last4,  int expMonth,  int expYear,  bool isDefault,  String? wallet)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentMethodEntity() when $default != null:
return $default(_that.id,_that.provider,_that.type,_that.brand,_that.last4,_that.expMonth,_that.expYear,_that.isDefault,_that.wallet);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String provider,  String type,  String brand,  String last4,  int expMonth,  int expYear,  bool isDefault,  String? wallet)  $default,) {final _that = this;
switch (_that) {
case _PaymentMethodEntity():
return $default(_that.id,_that.provider,_that.type,_that.brand,_that.last4,_that.expMonth,_that.expYear,_that.isDefault,_that.wallet);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String provider,  String type,  String brand,  String last4,  int expMonth,  int expYear,  bool isDefault,  String? wallet)?  $default,) {final _that = this;
switch (_that) {
case _PaymentMethodEntity() when $default != null:
return $default(_that.id,_that.provider,_that.type,_that.brand,_that.last4,_that.expMonth,_that.expYear,_that.isDefault,_that.wallet);case _:
  return null;

}
}

}

/// @nodoc


class _PaymentMethodEntity implements PaymentMethodEntity {
  const _PaymentMethodEntity({required this.id, required this.provider, required this.type, required this.brand, required this.last4, required this.expMonth, required this.expYear, this.isDefault = false, this.wallet});
  

@override final  String id;
@override final  String provider;
@override final  String type;
@override final  String brand;
@override final  String last4;
@override final  int expMonth;
@override final  int expYear;
@override@JsonKey() final  bool isDefault;
@override final  String? wallet;

/// Create a copy of PaymentMethodEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentMethodEntityCopyWith<_PaymentMethodEntity> get copyWith => __$PaymentMethodEntityCopyWithImpl<_PaymentMethodEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentMethodEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.type, type) || other.type == type)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.last4, last4) || other.last4 == last4)&&(identical(other.expMonth, expMonth) || other.expMonth == expMonth)&&(identical(other.expYear, expYear) || other.expYear == expYear)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.wallet, wallet) || other.wallet == wallet));
}


@override
int get hashCode => Object.hash(runtimeType,id,provider,type,brand,last4,expMonth,expYear,isDefault,wallet);

@override
String toString() {
  return 'PaymentMethodEntity(id: $id, provider: $provider, type: $type, brand: $brand, last4: $last4, expMonth: $expMonth, expYear: $expYear, isDefault: $isDefault, wallet: $wallet)';
}


}

/// @nodoc
abstract mixin class _$PaymentMethodEntityCopyWith<$Res> implements $PaymentMethodEntityCopyWith<$Res> {
  factory _$PaymentMethodEntityCopyWith(_PaymentMethodEntity value, $Res Function(_PaymentMethodEntity) _then) = __$PaymentMethodEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String provider, String type, String brand, String last4, int expMonth, int expYear, bool isDefault, String? wallet
});




}
/// @nodoc
class __$PaymentMethodEntityCopyWithImpl<$Res>
    implements _$PaymentMethodEntityCopyWith<$Res> {
  __$PaymentMethodEntityCopyWithImpl(this._self, this._then);

  final _PaymentMethodEntity _self;
  final $Res Function(_PaymentMethodEntity) _then;

/// Create a copy of PaymentMethodEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? provider = null,Object? type = null,Object? brand = null,Object? last4 = null,Object? expMonth = null,Object? expYear = null,Object? isDefault = null,Object? wallet = freezed,}) {
  return _then(_PaymentMethodEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,last4: null == last4 ? _self.last4 : last4 // ignore: cast_nullable_to_non_nullable
as String,expMonth: null == expMonth ? _self.expMonth : expMonth // ignore: cast_nullable_to_non_nullable
as int,expYear: null == expYear ? _self.expYear : expYear // ignore: cast_nullable_to_non_nullable
as int,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,wallet: freezed == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
