import 'package:cloud_firestore/cloud_firestore.dart';

class AuctionEntity {
  final String id;
  final String title;
  final double currentPrice;
  final String status;
  final String? imageUrl; // Додали поле для картинки

  AuctionEntity({
    required this.id,
    required this.title,
    required this.currentPrice,
    required this.status,
    this.imageUrl,
  });

  // Фабрика: перетворює дані з Firebase у зручний об'єкт
  factory AuctionEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Безпечно дістаємо картинку (якщо це список)
    String? img;
    if (data['images'] is List && (data['images'] as List).isNotEmpty) {
      img = data['images'][0];
    } else if (data['imageUrl'] is String) {
      img = data['imageUrl'];
    }

    return AuctionEntity(
      id: doc.id,
      title: data['title'] ?? 'Без назви',
      currentPrice: (data['currentPrice'] ?? 0).toDouble(),
      status: data['status'] ?? 'unknown',
      imageUrl: img,
    );
  }
}