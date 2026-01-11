enum DeliveryProvider {
  novaPoshtaBranch,
  novaPoshtaCourier,
  novaPoshtaLocker,
  ukrPoshta,
  meestExpress,
  pickup,
}

enum PaymentMethod {
  cashOnDelivery,
  cardOnline,
  applePay,
  googlePay,
  cardTransfer,
  cashPickup,
}

class DeliveryInfo {
  final DeliveryProvider provider;
  final PaymentMethod paymentMethod;
  final String city;
  final String departmentNumber;
  final String fullAddress;
  final String recipientName;
  final String recipientPhone;

  const DeliveryInfo({
    required this.provider,
    this.paymentMethod = PaymentMethod.cashOnDelivery,
    required this.city,
    this.departmentNumber = '',
    this.fullAddress = '',
    required this.recipientName,
    required this.recipientPhone,
  });

  Map<String, dynamic> toMap() {
    return {
      'provider': provider.name,
      'paymentMethod': paymentMethod.name,
      'city': city,
      'departmentNumber': departmentNumber,
      'fullAddress': fullAddress,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
    };
  }

  factory DeliveryInfo.fromMap(Map<String, dynamic> map) {
    final providerRaw = (map['provider'] as String?) ?? DeliveryProvider.novaPoshtaBranch.name;
    final provider = DeliveryProvider.values.firstWhere(
      (p) => p.name == providerRaw,
      orElse: () => DeliveryProvider.novaPoshtaBranch,
    );

    final paymentRaw = (map['paymentMethod'] as String?) ?? PaymentMethod.cashOnDelivery.name;
    final paymentMethod = PaymentMethod.values.firstWhere(
      (p) => p.name == paymentRaw,
      orElse: () => PaymentMethod.cashOnDelivery,
    );

    return DeliveryInfo(
      provider: provider,
      paymentMethod: paymentMethod,
      city: (map['city'] as String?) ?? '',
      departmentNumber: (map['departmentNumber'] as String?) ?? '',
      fullAddress: (map['fullAddress'] as String?) ?? '',
      recipientName: (map['recipientName'] as String?) ?? '',
      recipientPhone: (map['recipientPhone'] as String?) ?? '',
    );
  }
}
