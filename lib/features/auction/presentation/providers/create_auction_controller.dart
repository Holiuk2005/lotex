import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // <-- ОБОВ'ЯЗКОВИЙ ІМПОРТ
import 'package:lotex/features/auth/data/repositories/presentation/providers/auth_state_provider.dart';
import '../../data/repositories/auction_repository.dart';

final createAuctionControllerProvider = AsyncNotifierProvider<CreateAuctionController, void>(
  CreateAuctionController.new,
);

class CreateAuctionController extends AsyncNotifier<void> {
  late final AuctionRepository _repository;

  @override
  Future<void> build() async {
    _repository = ref.read(auctionRepositoryProvider);
  }

  Future<void> create({
    required String title,
    required String description,
    required double startPrice,
    required DateTime endDate,
    required XFile image, // <-- ВИКОРИСТОВУЄМО XFile (працює і на Web, і на телефоні)
  }) async {
    state = const AsyncValue.loading();
    try {
      final userId = ref.read(currentUserProvider)?.uid ?? 'test_user_id_123';
      
      await _repository.createAuction(
        title: title,
        description: description,
        startPrice: startPrice,
        endDate: endDate,
        imageFile: image, // Передаємо XFile далі
        sellerId: userId,
      );
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}