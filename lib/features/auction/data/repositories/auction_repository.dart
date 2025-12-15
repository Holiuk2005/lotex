import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/auction_entity.dart';

final auctionRepositoryProvider = Provider((ref) => AuctionRepository(
  firestore: FirebaseFirestore.instance,
  storage: FirebaseStorage.instance,
));

class AuctionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  AuctionRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  // Створення
  Future<void> createAuction({
    required String title,
    required String description,
    required double startPrice,
    required DateTime endDate,
    required File imageFile,
    required String sellerId,
  }) async {
    try {
      final docRef = _firestore.collection('auctions').doc();
      final auctionId = docRef.id;

      // Upload Image
      final storageRef = _storage.ref().child('auctions/$auctionId.jpg');
      final uploadTask = await storageRef.putFile(imageFile);
      final imageUrl = await uploadTask.ref.getDownloadURL();

      final auction = AuctionEntity(
        id: auctionId,
        title: title,
        description: description,
        imageUrl: imageUrl,
        startPrice: startPrice,
        currentPrice: startPrice,
        endDate: endDate,
        sellerId: sellerId,
      );

      await docRef.set(auction.toDocument());
    } catch (e) {
      throw Exception('Помилка створення аукціону: $e');
    }
  }

  // Читання (Stream)
  Stream<List<AuctionEntity>> getAuctionsStream() {
    return _firestore
        .collection('auctions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AuctionEntity.fromDocument(doc))
              .toList();
        });
  }
}