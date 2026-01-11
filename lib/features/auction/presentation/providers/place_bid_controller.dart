import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotex/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:lotex/core/errors/failure.dart';
import '../../data/repositories/auction_repository.dart';

final placeBidControllerProvider =
    AsyncNotifierProvider.autoDispose<PlaceBidController, void>(
  PlaceBidController.new,
);

class PlaceBidController extends AutoDisposeAsyncNotifier<void> {
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
      state = AsyncValue.error(const AuthRequiredFailure(), StackTrace.current);
      return;
    }

    String resolveUserName() {
      final dn = (currentUser.displayName ?? '').trim();
      if (dn.isNotEmpty) return dn;

      final email = currentUser.email.trim();
      if (email.isNotEmpty) {
        final idx = email.indexOf('@');
        return idx > 0 ? email.substring(0, idx) : email;
      }
      final uid = currentUser.uid;
      if (uid.isEmpty) return 'User';
      final head = uid.length >= 6 ? uid.substring(0, 6) : uid;
      return '$head…';
    }

    state = const AsyncValue.loading();
    try {
      await _repository.placeBid(
        auctionId: auctionId,
        bidAmount: bidAmount,
        userId: currentUser.uid,
        userName: resolveUserName(),
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      // Help debug cases where UI only shows a generic/"Unknown" message.
      // This prints the real exception to the debug console.
      // ignore: avoid_print
      print('REAL ERROR: $e');
      // ignore: avoid_print
      print('REAL STACK: $st');
      state = AsyncValue.error(e, st);
    }
  }
}
