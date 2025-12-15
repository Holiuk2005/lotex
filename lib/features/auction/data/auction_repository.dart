import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // Важливий імпорт для XFile
import '../domain/entities/auction_entity.dart';

// Провайдер
final auctionRepositoryProvider = Provider<AuctionRepository>((ref) {
  return AuctionRepository(
    FirebaseFirestore.instance,
    FirebaseStorage.instance,
  );
});

class AuctionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  AuctionRepository(this._firestore, this._storage);

  // Метод створення аукціону (ВИПРАВЛЕНИЙ)
  Future<void> createAuction({
    required String title,
    required String description,
    required double startPrice,
    required DateTime endDate,
    required XFile imageFile, // <-- Тепер приймаємо XFile
    required String sellerId,
  }) async {
    try {
      // 1. ПІДГОТОВКА ЗОБРАЖЕННЯ
      // На Web не можна отримати 'path' до файлу так само, як на телефоні.
      // Тому ми читаємо файл як байти. Це працює всюди.
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Створюємо шлях у хмарі: auction_images/часовамітка_назва.jpg
      final storageRef = _storage.ref().child(
        'auction_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}',
      );

      // 2. ЗАВАНТАЖЕННЯ (putData замість putFile)
      final uploadTask = await storageRef.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'), // Допомагає браузеру зрозуміти, що це картинка
      );

      // Отримуємо посилання на картинку
      final imageUrl = await uploadTask.ref.getDownloadURL();

      // 3. ЗБЕРЕЖЕННЯ ДАНИХ В БАЗУ
      await _firestore.collection('auctions').add({
        'title': title,
        'description': description,
        'startPrice': startPrice,
        'currentPrice': startPrice,
        'endDate': Timestamp.fromDate(endDate),
        'imageUrl': imageUrl,
        'sellerId': sellerId,
        'bids': [], // Початковий список ставок пустий
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
    } catch (e) {
      throw Exception('Failed to create auction: $e');
    }
  }

  // Метод отримання списку аукціонів (залиште його як є, або ось приклад)
  Stream<List<AuctionEntity>> getAuctions() {
    return _firestore
        .collection('auctions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return AuctionEntity(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          startPrice: (data['startPrice'] as num).toDouble(),
          currentPrice: (data['currentPrice'] as num).toDouble(),
          endDate: (data['endDate'] as Timestamp).toDate(),
          sellerId: data['sellerId'] ?? '',
        );
      }).toList();
    });
  }
}