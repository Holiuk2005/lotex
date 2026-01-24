enum DeliveryProvider {
  novaPoshta,
  novaPoshtaBranch,
  novaPoshtaCourier,
  novaPoshtaLocker,
  ukrPoshta,
  meestExpress,
  pickup,
}

extension DeliveryProviderUiX on DeliveryProvider {
  String get assetPath {
    switch (this) {
      case DeliveryProvider.novaPoshta:
      case DeliveryProvider.novaPoshtaBranch:
      case DeliveryProvider.novaPoshtaCourier:
      case DeliveryProvider.novaPoshtaLocker:
        return 'assets/logos/shipping/nova_poshta.svg';
      case DeliveryProvider.ukrPoshta:
        return 'assets/logos/shipping/ukrposhta.svg';
      case DeliveryProvider.meestExpress:
        return 'assets/logos/shipping/meest.svg';
      case DeliveryProvider.pickup:
        return '';
    }
  }

  String get iconPath => assetPath;

  String displayName({String localeCode = 'uk'}) {
    final isUk = localeCode.toLowerCase().startsWith('uk');
    switch (this) {
      case DeliveryProvider.novaPoshta:
      case DeliveryProvider.novaPoshtaBranch:
        return isUk ? 'Нова Пошта' : 'Nova Poshta';
      case DeliveryProvider.novaPoshtaCourier:
        return isUk ? "Нова Пошта (Кур'єр)" : 'Nova Poshta (Courier)';
      case DeliveryProvider.novaPoshtaLocker:
        return isUk ? 'Нова Пошта (Поштомат)' : 'Nova Poshta (Locker)';
      case DeliveryProvider.ukrPoshta:
        return isUk ? 'Укрпошта' : 'Ukrposhta';
      case DeliveryProvider.meestExpress:
        return isUk ? 'Meest Express' : 'Meest Express';
      case DeliveryProvider.pickup:
        return isUk ? 'Самовивіз' : 'Pickup';
    }
  }
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
