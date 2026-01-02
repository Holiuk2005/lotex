import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/auction.dart';

// Провайдер для доступу до репозиторію
final auctionRepositoryProvider = Provider((ref) => AuctionRepository());

// Провайдер для отримання списку аукціонів (Stream)
final activeAuctionsProvider = StreamProvider<List<Auction>>((ref) {
  return ref.watch(auctionRepositoryProvider).getAuctions();
});

class AuctionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Отримати потік активних аукціонів
  Stream<List<Auction>> getAuctions() {
    return _firestore
        .collection('auctions')
        .where('status', isEqualTo: 'active') // Фільтр тільки активних
        .orderBy('endsAt') // Сортування за часом завершення
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Auction.fromFirestore(doc))
            .toList());
  }
}