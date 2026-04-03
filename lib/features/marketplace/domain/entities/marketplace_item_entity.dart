import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../auction/domain/entities/delivery_info.dart';

part 'marketplace_item_entity.freezed.dart';

@freezed
abstract class MarketplaceItemEntity with _$MarketplaceItemEntity {
  const MarketplaceItemEntity._();

  const factory MarketplaceItemEntity({
    required String id,
    required String title,
    required String description,
    required String imageUrl,
    String? imageBase64,
    @Default('') String category,
    @Default('UAH') String currency,
    required double price,
    required String sellerId,
    String? winnerId,
    @Default('active') String status,
    DeliveryInfo? deliveryInfo,
    DateTime? createdAt,
  }) = _MarketplaceItemEntity;

  Map<String, dynamic> toDocument() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'imageBase64': imageBase64,
      'category': category,
      'currency': currency,
      'price': price,
      'sellerId': sellerId,
      'winnerId': winnerId,
      'status': status,
      'deliveryInfo': deliveryInfo?.toMap(),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory MarketplaceItemEntity.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    double numOrStringToDouble(dynamic v, {double fallback = 0.0}) {
      if (v is num) return v.toDouble();
      if (v is String) {
        final parsed = double.tryParse(v.trim().replaceAll(',', '.'));
        if (parsed != null) return parsed;
      }
      return fallback;
    }

    final deliveryRaw = data['deliveryInfo'];
    DeliveryInfo? delivery;
    if (deliveryRaw is Map<String, dynamic>) {
      delivery = DeliveryInfo.fromMap(deliveryRaw);
    } else if (deliveryRaw is Map) {
      delivery = DeliveryInfo.fromMap(Map<String, dynamic>.from(deliveryRaw));
    }

    return MarketplaceItemEntity(
      id: doc.id,
      title: data['title'] ?? 'Без назви',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      imageBase64: data['imageBase64'],
      category: (data['category'] as String?)?.trim() ?? '',
      currency: (data['currency'] as String?)?.trim().toUpperCase() ?? 'UAH',
      price: numOrStringToDouble(data['price'], fallback: 0.0),
      sellerId: data['sellerId'] ?? '',
      winnerId: data['winnerId'],
      status: data['status'] ?? 'active',
      deliveryInfo: delivery,
      createdAt: () {
        final raw = data['createdAt'];
        if (raw is Timestamp) return raw.toDate();
        if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
        return null;
      }(),
    );
  }
}
