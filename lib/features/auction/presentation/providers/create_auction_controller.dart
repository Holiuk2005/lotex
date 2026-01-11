import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // <-- ОБОВ'ЯЗКОВИЙ ІМПОРТ
import 'package:lotex/features/auth/presentation/providers/auth_state_provider.dart';
import '../../data/repositories/auction_repository.dart';

final createAuctionControllerProvider = AsyncNotifierProvider<CreateAuctionController, void>(
  CreateAuctionController.new,
);

class CreateAuctionController extends AsyncNotifier<void> {
  late final AuctionRepository _repository;

  @override
  void build() {
    _repository = ref.read(auctionRepositoryProvider);
  }

  Future<void> create({
    required String title,
    required String description,
    required double startPrice,
    double? buyoutPrice,
    required DateTime endDate,
    required XFile image, // <-- ВИКОРИСТОВУЄМО XFile (працює і на Web, і на телефоні)
  }) async {
    state = const AsyncValue.loading();
    try {
      final userId = ref.read(currentUserProvider)?.uid;
      if (userId == null || userId.isEmpty) {
        throw Exception('Потрібна авторизація');
      }
      
      await _repository.createAuction(
        title: title,
        description: description,
        startPrice: startPrice,
        buyoutPrice: buyoutPrice,
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