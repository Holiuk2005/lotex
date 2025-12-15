import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    required File image,
  }) async {
    state = const AsyncValue.loading();
    try {
      const userId = "test_user_id_123"; // Заглушка, поки немає Auth
      await _repository.createAuction(
        title: title,
        description: description,
        startPrice: startPrice,
        endDate: endDate,
        imageFile: image,
        sellerId: userId,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}