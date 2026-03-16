
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lotex/core/errors/failure_mapper.dart';
import '../domain/entities/auction_entity.dart';

class FirebaseAuctionDatasource {
  final FirebaseFirestore firestore;
  FirebaseAuctionDatasource(this.firestore);

  Future<List<AuctionEntity>> getAuctions() async {
    try {
      final snapshot = await firestore
          .collection('auctions')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => AuctionEntity.fromDocument(doc)).toList();
    } catch (e) {
      developer.log('[FirebaseAuctionDatasource] getAuctions помилка: $e');
      throw FailureMapper.from(e);
    }
  }

  Future<void> createAuction({
    required String title,
    required String description,
    required double startPrice,
    required DateTime endDate,
    required String imageBase64,
  }) async {
    try {
      // Отримуємо sellerId з Firebase Auth — порожній рядок спричиняв порушення правил Firestore.
      final sellerId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final auction = AuctionEntity(
        id: '',
        title: title,
        description: description,
        imageUrl: '',
        imageBase64: imageBase64,
        startPrice: startPrice,
        currentPrice: startPrice,
        endDate: endDate,
        sellerId: sellerId,
      );
      await firestore.collection('auctions').add(auction.toDocument());
    } catch (e) {
      developer.log('[FirebaseAuctionDatasource] createAuction помилка: $e');
      throw FailureMapper.from(e);
    }
  }
}
