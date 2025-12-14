import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Ось тут ми підключаємо файл з попереднього кроку:
import '../domain/auction_entity.dart';

final auctionRepositoryProvider = Provider((ref) => AuctionRepository());

final auctionStreamProvider = StreamProvider<List<AuctionEntity>>((ref) {
  final repository = ref.watch(auctionRepositoryProvider);
  return repository.getAuctions();
});

class AuctionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AuctionEntity>> getAuctions() {
    return _firestore.collection('auctions').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AuctionEntity.fromFirestore(doc)).toList();
    });
  }
}