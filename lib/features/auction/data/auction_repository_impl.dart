
// Увага: цей файл є запасною реалізацією інтерфейсу AuctionRepository.
// У проекті активно використовується AuctionRepository (data/repositories/auction_repository.dart),
// тому AuctionRepositoryImpl зараз не задіяний у продакшені.
// Якщо знадобиться — підключіть його через Riverpod провайдер.
import 'dart:developer' as developer;

import '../domain/auction_repository.dart';
import '../domain/entities/auction_entity.dart';
import 'firebase_auction_datasource.dart';

class AuctionRepositoryImpl implements AuctionRepository {
  final FirebaseAuctionDatasource datasource;
  AuctionRepositoryImpl(this.datasource);

  @override
  Future<List<AuctionEntity>> getAuctions() {
    // Datasource вже маппує помилки через FailureMapper — додатковий try/catch не потрібен.
    developer.log('[AuctionRepositoryImpl] getAuctions викликано');
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
    // Datasource вже маппує помилки через FailureMapper — додатковий try/catch не потрібен.
    developer.log('[AuctionRepositoryImpl] createAuction викликано');
    return datasource.createAuction(
      title: title,
      description: description,
      startPrice: startPrice,
      endDate: endDate,
      imageBase64: imageBase64,
    );
  }
}
