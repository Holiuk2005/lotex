import 'package:lotex/features/auction/domain/entities/auction_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotex/features/auction/data/repositories/auction_repository.dart';

final auctionsProvider = FutureProvider<List<AuctionEntity>>((ref) {
  final repo = ref.read(auctionRepositoryProvider);
  return repo.fetchAuctionsPage(limit: 50).then((p) => p.items);
});
