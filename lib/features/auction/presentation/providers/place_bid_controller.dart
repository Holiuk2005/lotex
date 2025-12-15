import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotex/features/auth/presentation/providers/auth_state_provider.dart';
import '../../data/repositories/auction_repository.dart';

final placeBidControllerProvider = AsyncNotifierProvider.autoDispose<PlaceBidController, void>(
  PlaceBidController.new,
);

class PlaceBidController extends AsyncNotifier<void> {
  late final AuctionRepository _repository;

  @override
  Future<void> build() async {
    _repository = ref.read(auctionRepositoryProvider);
  }

  Future<void> placeBid({
    required String auctionId,
    required double bidAmount,
  }) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      state = AsyncValue.error('Для ставки потрібна авторизація', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();
    try {
      await _repository.placeBid(
        auctionId: auctionId,
        bidAmount: bidAmount,
        userId: currentUser.uid,
        userName: currentUser.email.split('@').first,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}