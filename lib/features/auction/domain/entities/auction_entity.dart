import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'delivery_info.dart';

part 'auction_entity.freezed.dart';

@freezed
abstract class AuctionEntity with _$AuctionEntity {
  const AuctionEntity._();

  const factory AuctionEntity({
    required String id,
    required String title,
    required String description,
    required String imageUrl,
    String? imageBase64,
    required double startPrice,
    required double currentPrice,
    double? buyoutPrice,
    required DateTime endDate,
    required String sellerId,
    @Default(0) int bidCount,
    String? lastBidderId,
    String? winnerId,
    @Default('active') String status,
    DeliveryInfo? deliveryInfo,
  }) = _AuctionEntity;

  // Конвертація В документ Firestore
  Map<String, dynamic> toDocument() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'imageBase64': imageBase64,
      'startPrice': startPrice,
      'currentPrice': currentPrice,
      'buyoutPrice': buyoutPrice,
      'endDate': endDate.toIso8601String(),
      'sellerId': sellerId,
      'bidCount': bidCount,
      'lastBidderId': lastBidderId,
      'winnerId': winnerId,
      'status': status,
      'deliveryInfo': deliveryInfo?.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Конвертація З документа Firestore
  factory AuctionEntity.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

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

    return AuctionEntity(
      id: doc.id,
      title: data['title'] ?? 'Без назви',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      imageBase64: data['imageBase64'],
      startPrice: numOrStringToDouble(data['startPrice'], fallback: 0.0),
      currentPrice: numOrStringToDouble(data['currentPrice'], fallback: 0.0),
      buyoutPrice: () {
        final dynamic raw = data['buyoutPrice'] ??
            data['buyout'] ??
            data['buyout_price'] ??
            data['instantBuyPrice'] ??
            data['instantBuy'] ??
            data['buyNowPrice'];
        if (raw == null) return null;
        final v = numOrStringToDouble(raw, fallback: 0.0);
        return v > 0 ? v : null;
      }(),
      endDate: DateTime.tryParse(data['endDate'] ?? '') ??
          DateTime.now().add(const Duration(days: 1)),
      sellerId: data['sellerId'] ?? '',
      bidCount: data['bidCount'] ?? 0,
      lastBidderId: data['lastBidderId'],
      winnerId: data['winnerId'],
      status: data['status'] ?? 'active',
      deliveryInfo: delivery,
    );
  }
}
