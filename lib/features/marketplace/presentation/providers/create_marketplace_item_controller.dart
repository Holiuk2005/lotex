import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../data/repositories/marketplace_repository.dart';
import 'marketplace_providers.dart';

final createMarketplaceItemControllerProvider =
    StateNotifierProvider<CreateMarketplaceItemController, AsyncValue<void>>((ref) {
  return CreateMarketplaceItemController(
    ref.watch(marketplaceRepositoryProvider),
    ref.watch(currentUserProvider)?.uid,
  );
});

class CreateMarketplaceItemController extends StateNotifier<AsyncValue<void>> {
  final MarketplaceRepository _repo;
  final String? _uid;

  CreateMarketplaceItemController(this._repo, this._uid)
      : super(const AsyncValue.data(null));

  Future<void> create({
    required String title,
    required String description,
    required String category,
    required String currency,
    required double price,
    required XFile image,
  }) async {
    final currentUid = _uid;
    if (currentUid == null) {
      state = AsyncValue.error('Користувач не авторизований', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();
    try {
      await _repo.createItem(
        title: title.trim(),
        description: description.trim(),
        category: category,
        currency: currency,
        price: price,
        sellerId: currentUid,
        image: image,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
