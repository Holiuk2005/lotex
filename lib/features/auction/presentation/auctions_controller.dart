import 'package:lotex/features/auction/domain/entities/auction_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/auction_repository.dart';

final auctionRepositoryProvider = Provider<AuctionRepository>((ref) {
  throw UnimplementedError();
});

final auctionsProvider = FutureProvider<List<AuctionEntity>>((ref) {
  return ref.read(auctionRepositoryProvider).getAuctions();
});
