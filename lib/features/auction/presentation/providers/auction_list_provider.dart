import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auction_repository.dart';
import '../../domain/entities/auction_entity.dart';

final auctionListProvider = StreamProvider<List<AuctionEntity>>((ref) {
  final repository = ref.watch(auctionRepositoryProvider);
  return repository.getAuctionsStream();
});