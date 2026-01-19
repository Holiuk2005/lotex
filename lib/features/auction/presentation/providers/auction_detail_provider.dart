import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lotex/features/auction/domain/entities/auction_entity.dart';

final auctionDetailProvider = StreamProvider.autoDispose.family<AuctionEntity, String>((ref, auctionId) {
  final docRef = FirebaseFirestore.instance.collection('auctions').doc(auctionId);
  return docRef.snapshots().map((doc) {
    if (!doc.exists) {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'not-found',
        message: 'Auction not found',
      );
    }
    return AuctionEntity.fromDocument(doc);
  });
});
