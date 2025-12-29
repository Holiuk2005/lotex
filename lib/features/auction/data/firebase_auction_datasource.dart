
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/auction_entity.dart';

class FirebaseAuctionDatasource {
  final FirebaseFirestore firestore;
  FirebaseAuctionDatasource(this.firestore);

  Future<List<AuctionEntity>> getAuctions() async {
    final snapshot = await firestore
        .collection('auctions')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => AuctionEntity.fromDocument(doc)).toList();
  }

  Future<void> createAuction({
    required String title,
    required String description,
    required double startPrice,
    required DateTime endDate,
    required String imageBase64,
  }) async {
    final auction = AuctionEntity(
      id: '',
      title: title,
      description: description,
      imageUrl: '',
      imageBase64: imageBase64,
      startPrice: startPrice,
      currentPrice: startPrice,
      endDate: endDate,
      sellerId: '',
    );
    await firestore.collection('auctions').add(auction.toDocument());
  }
}
