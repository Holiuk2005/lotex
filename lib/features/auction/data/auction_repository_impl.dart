
import '../domain/auction_repository.dart';
import '../domain/entities/auction_entity.dart';
import 'firebase_auction_datasource.dart';
import 'package:lotex/core/errors/failure_mapper.dart';

import 'dart:developer' as developer;

class AuctionRepositoryImpl implements AuctionRepository {
  final FirebaseAuctionDatasource datasource;
  AuctionRepositoryImpl(this.datasource);

  @override
  Future<List<AuctionEntity>> getAuctions() {
    try {
      return datasource.getAuctions();
    } catch (e) {
      developer.log('Auction getAuctions error: $e');
      throw FailureMapper.from(e);
    }
  }

  @override
  Future<void> createAuction({
    required String title,
    required String description,
    required double startPrice,
    required DateTime endDate,
    required String imageBase64,
  }) {
    try {
      return datasource.createAuction(
        title: title,
        description: description,
        startPrice: startPrice,
        endDate: endDate,
        imageBase64: imageBase64,
      );
    } catch (e) {
      developer.log('createAuction error: $e');
      throw FailureMapper.from(e);
    }
  }
}
