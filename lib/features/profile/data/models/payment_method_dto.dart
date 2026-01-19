import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:lotex/features/profile/domain/entities/payment_method_entity.dart';

part 'payment_method_dto.freezed.dart';
part 'payment_method_dto.g.dart';

@freezed
abstract class PaymentMethodDto with _$PaymentMethodDto {
  const PaymentMethodDto._();

  const factory PaymentMethodDto({
    required String provider,
    required String type,
    required String brand,
    required String last4,
    required int expMonth,
    required int expYear,
    @Default(false) bool isDefault,
    String? wallet,
  }) = _PaymentMethodDto;

  factory PaymentMethodDto.fromJson(Map<String, dynamic> json) => _$PaymentMethodDtoFromJson(json);

  PaymentMethodEntity toEntity(String id) {
    return PaymentMethodEntity(
      id: id,
      provider: provider,
      type: type,
      brand: brand,
      last4: last4,
      expMonth: expMonth,
      expYear: expYear,
      isDefault: isDefault,
      wallet: wallet,
    );
  }
}

