import 'package:cloud_firestore/cloud_firestore.dart';

class Auction {
  final String id;
  final String title;
  final String description;
  final double currentPrice;
  final DateTime endsAt;
  final String imageUrl;

  Auction({
    required this.id,
    required this.title,
    required this.description,
    required this.currentPrice,
    required this.endsAt,
    required this.imageUrl,
  });

  // Фабрика для створення об'єкта з Firebase
  factory Auction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Auction(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      currentPrice: (data['currentPrice'] ?? 0).toDouble(),
      endsAt: (data['endsAt'] as Timestamp).toDate(),
      imageUrl: (data['images'] as List).isNotEmpty ? data['images'][0] : '',
    );
  }
}