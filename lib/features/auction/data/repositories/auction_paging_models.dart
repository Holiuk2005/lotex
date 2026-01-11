import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/auction_entity.dart';

class AuctionPage {
  final List<AuctionEntity> items;
  final QueryDocumentSnapshot<Map<String, dynamic>>? lastDoc;
  final bool hasMore;

  const AuctionPage({
    required this.items,
    required this.lastDoc,
    required this.hasMore,
  });
}
