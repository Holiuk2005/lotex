import 'package:cloud_firestore/cloud_firestore.dart';

class AuctionEntity {
  final String id;
  final String title;
  final double currentPrice;
  final String status;
  final String? imageUrl;

  AuctionEntity({
    required this.id,
    required this.title,
    required this.currentPrice,
    required this.status,
    this.imageUrl,
  });

  factory AuctionEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AuctionEntity(
      id: doc.id,
      title: data['title'] ?? 'Без назви',
      currentPrice: (data['currentPrice'] ?? 0).toDouble(),
      status: data['status'] ?? 'unknown',
      imageUrl: data['imageUrl'],
    );
  }
}