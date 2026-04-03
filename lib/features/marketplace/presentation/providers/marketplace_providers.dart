import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/marketplace_item_entity.dart';
import '../../data/repositories/marketplace_repository.dart';

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  return MarketplaceRepository();
});

final marketplaceDetailProvider = StreamProvider.family<MarketplaceItemEntity, String>((ref, id) {
  return ref.watch(marketplaceRepositoryProvider).watchItem(id);
});
