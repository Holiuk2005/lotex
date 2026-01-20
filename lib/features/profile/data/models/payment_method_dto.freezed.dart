// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_method_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentMethodDto {

 String get provider; String get type; String get brand; String get last4; int get expMonth; int get expYear; bool get isDefault; String? get wallet;
/// Create a copy of PaymentMethodDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentMethodDtoCopyWith<PaymentMethodDto> get copyWith => _$PaymentMethodDtoCopyWithImpl<PaymentMethodDto>(this as PaymentMethodDto, _$identity);

  /// Serializes this PaymentMethodDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentMethodDto&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.type, type) || other.type == type)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.last4, last4) || other.last4 == last4)&&(identical(other.expMonth, expMonth) || other.expMonth == expMonth)&&(identical(other.expYear, expYear) || other.expYear == expYear)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.wallet, wallet) || other.wallet == wallet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,provider,type,brand,last4,expMonth,expYear,isDefault,wallet);

@override
String toString() {
  return 'PaymentMethodDto(provider: $provider, type: $type, brand: $brand, last4: $last4, expMonth: $expMonth, expYear: $expYear, isDefault: $isDefault, wallet: $wallet)';
}


}

/// @nodoc
abstract mixin class $PaymentMethodDtoCopyWith<$Res>  {
  factory $PaymentMethodDtoCopyWith(PaymentMethodDto value, $Res Function(PaymentMethodDto) _then) = _$PaymentMethodDtoCopyWithImpl;
@useResult
$Res call({
 String provider, String type, String brand, String last4, int expMonth, int expYear, bool isDefault, String? wallet
});




}
/// @nodoc
class _$PaymentMethodDtoCopyWithImpl<$Res>
    implements $PaymentMethodDtoCopyWith<$Res> {
  _$PaymentMethodDtoCopyWithImpl(this._self, this._then);

  final PaymentMethodDto _self;
  final $Res Function(PaymentMethodDto) _then;

/// Create a copy of PaymentMethodDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? provider = null,Object? type = null,Object? brand = null,Object? last4 = null,Object? expMonth = null,Object? expYear = null,Object? isDefault = null,Object? wallet = freezed,}) {
  return _then(_self.copyWith(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
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


/// Adds pattern-matching-related methods to [PaymentMethodDto].
extension PaymentMethodDtoPatterns on PaymentMethodDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentMethodDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentMethodDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentMethodDto value)  $default,){
final _that = this;
switch (_that) {
case _PaymentMethodDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentMethodDto value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentMethodDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String provider,  String type,  String brand,  String last4,  int expMonth,  int expYear,  bool isDefault,  String? wallet)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentMethodDto() when $default != null:
return $default(_that.provider,_that.type,_that.brand,_that.last4,_that.expMonth,_that.expYear,_that.isDefault,_that.wallet);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String provider,  String type,  String brand,  String last4,  int expMonth,  int expYear,  bool isDefault,  String? wallet)  $default,) {final _that = this;
switch (_that) {
case _PaymentMethodDto():
return $default(_that.provider,_that.type,_that.brand,_that.last4,_that.expMonth,_that.expYear,_that.isDefault,_that.wallet);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String provider,  String type,  String brand,  String last4,  int expMonth,  int expYear,  bool isDefault,  String? wallet)?  $default,) {final _that = this;
switch (_that) {
case _PaymentMethodDto() when $default != null:
return $default(_that.provider,_that.type,_that.brand,_that.last4,_that.expMonth,_that.expYear,_that.isDefault,_that.wallet);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentMethodDto extends PaymentMethodDto {
  const _PaymentMethodDto({required this.provider, required this.type, required this.brand, required this.last4, required this.expMonth, required this.expYear, this.isDefault = false, this.wallet}): super._();
  factory _PaymentMethodDto.fromJson(Map<String, dynamic> json) => _$PaymentMethodDtoFromJson(json);

@override final  String provider;
@override final  String type;
@override final  String brand;
@override final  String last4;
@override final  int expMonth;
@override final  int expYear;
@override@JsonKey() final  bool isDefault;
@override final  String? wallet;

/// Create a copy of PaymentMethodDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentMethodDtoCopyWith<_PaymentMethodDto> get copyWith => __$PaymentMethodDtoCopyWithImpl<_PaymentMethodDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentMethodDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentMethodDto&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.type, type) || other.type == type)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.last4, last4) || other.last4 == last4)&&(identical(other.expMonth, expMonth) || other.expMonth == expMonth)&&(identical(other.expYear, expYear) || other.expYear == expYear)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.wallet, wallet) || other.wallet == wallet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,provider,type,brand,last4,expMonth,expYear,isDefault,wallet);

@override
String toString() {
  return 'PaymentMethodDto(provider: $provider, type: $type, brand: $brand, last4: $last4, expMonth: $expMonth, expYear: $expYear, isDefault: $isDefault, wallet: $wallet)';
}


}

/// @nodoc
abstract mixin class _$PaymentMethodDtoCopyWith<$Res> implements $PaymentMethodDtoCopyWith<$Res> {
  factory _$PaymentMethodDtoCopyWith(_PaymentMethodDto value, $Res Function(_PaymentMethodDto) _then) = __$PaymentMethodDtoCopyWithImpl;
@override @useResult
$Res call({
 String provider, String type, String brand, String last4, int expMonth, int expYear, bool isDefault, String? wallet
});




}
/// @nodoc
class __$PaymentMethodDtoCopyWithImpl<$Res>
    implements _$PaymentMethodDtoCopyWith<$Res> {
  __$PaymentMethodDtoCopyWithImpl(this._self, this._then);

  final _PaymentMethodDto _self;
  final $Res Function(_PaymentMethodDto) _then;

/// Create a copy of PaymentMethodDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? provider = null,Object? type = null,Object? brand = null,Object? last4 = null,Object? expMonth = null,Object? expYear = null,Object? isDefault = null,Object? wallet = freezed,}) {
  return _then(_PaymentMethodDto(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
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
