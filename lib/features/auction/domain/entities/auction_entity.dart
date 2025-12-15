import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auction_entity.freezed.dart';

@freezed
abstract class AuctionEntity with _$AuctionEntity {
  const AuctionEntity._();

  const factory AuctionEntity({
    required String id,
    required String title,
    required String description,
    required String imageUrl,
    required double startPrice,
    required double currentPrice,
    required DateTime endDate,
    required String sellerId,
    @Default(0) int bidCount,
  }) = _AuctionEntity;

  // Конвертація В документ Firestore
  Map<String, dynamic> toDocument() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'startPrice': startPrice,
      'currentPrice': currentPrice,
      'endDate': endDate.toIso8601String(),
      'sellerId': sellerId,
      'bidCount': bidCount,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Конвертація З документа Firestore
  factory AuctionEntity.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AuctionEntity(
      id: doc.id,
      title: data['title'] ?? 'Без назви',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      startPrice: (data['startPrice'] as num?)?.toDouble() ?? 0.0,
      currentPrice: (data['currentPrice'] as num?)?.toDouble() ?? 0.0,
      endDate: DateTime.tryParse(data['endDate'] ?? '') ?? DateTime.now().add(const Duration(days: 1)),
      sellerId: data['sellerId'] ?? '',
      bidCount: data['bidCount'] ?? 0,
    );
  }
}