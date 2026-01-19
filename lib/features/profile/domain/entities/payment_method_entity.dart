import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_method_entity.freezed.dart';

@freezed
abstract class PaymentMethodEntity with _$PaymentMethodEntity {
  const factory PaymentMethodEntity({
    required String id,
    required String provider,
    required String type,
    required String brand,
    required String last4,
    required int expMonth,
    required int expYear,
    @Default(false) bool isDefault,
    String? wallet,
  }) = _PaymentMethodEntity;
}
