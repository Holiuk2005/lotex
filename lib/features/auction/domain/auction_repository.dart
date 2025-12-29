
import 'entities/auction_entity.dart';

abstract class AuctionRepository {
  Future<List<AuctionEntity>> getAuctions();
  Future<void> createAuction({
    required String title,
    required String description,
    required double startPrice,
    required DateTime endDate,
    required String imageBase64,
  });
}
