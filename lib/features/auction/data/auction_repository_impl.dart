
import '../domain/auction_repository.dart';
import '../domain/entities/auction_entity.dart';
import 'firebase_auction_datasource.dart';

class AuctionRepositoryImpl implements AuctionRepository {
  final FirebaseAuctionDatasource datasource;
  AuctionRepositoryImpl(this.datasource);

  @override
  Future<List<AuctionEntity>> getAuctions() {
    return datasource.getAuctions();
  }

  @override
  Future<void> createAuction({
    required String title,
    required String description,
    required double startPrice,
    required DateTime endDate,
    required String imageBase64,
  }) {
    return datasource.createAuction(
      title: title,
      description: description,
      startPrice: startPrice,
      endDate: endDate,
      imageBase64: imageBase64,
    );
  }
}
