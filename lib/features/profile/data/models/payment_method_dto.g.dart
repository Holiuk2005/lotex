// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentMethodDto _$PaymentMethodDtoFromJson(Map<String, dynamic> json) =>
    _PaymentMethodDto(
      provider: json['provider'] as String,
      type: json['type'] as String,
      brand: json['brand'] as String,
      last4: json['last4'] as String,
      expMonth: (json['expMonth'] as num).toInt(),
      expYear: (json['expYear'] as num).toInt(),
      isDefault: json['isDefault'] as bool? ?? false,
      wallet: json['wallet'] as String?,
    );

Map<String, dynamic> _$PaymentMethodDtoToJson(_PaymentMethodDto instance) =>
    <String, dynamic>{
      'provider': instance.provider,
      'type': instance.type,
      'brand': instance.brand,
      'last4': instance.last4,
      'expMonth': instance.expMonth,
      'expYear': instance.expYear,
      'isDefault': instance.isDefault,
      'wallet': instance.wallet,
    };
