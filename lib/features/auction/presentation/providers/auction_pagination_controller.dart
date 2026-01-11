import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auction_paging_models.dart';
import '../../data/repositories/auction_repository.dart';
import '../../domain/entities/auction_entity.dart';
import '../state/auction_list_state.dart';

final auctionPaginationControllerProvider = AutoDisposeAsyncNotifierProvider<
    AuctionPaginationController, AuctionListState>(
  AuctionPaginationController.new,
);

class AuctionPaginationController
    extends AutoDisposeAsyncNotifier<AuctionListState> {
  static const int _pageSize = 20;

  QueryDocumentSnapshot<Map<String, dynamic>>? _cursor;
  bool _hasMore = true;

  @override
  Future<AuctionListState> build() async {
    return _loadFirstPage();
  }

  Future<AuctionListState> _loadFirstPage() async {
    final repository = ref.read(auctionRepositoryProvider);
    try {
      final AuctionPage page = await repository.fetchAuctionsPage(
        startAfter: null,
        limit: _pageSize,
      );
      _cursor = page.lastDoc;
      _hasMore = page.hasMore;
      return AuctionListState.success(items: page.items, hasMore: _hasMore);
    } catch (e) {
      return AuctionListState.error(error: e);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.data(AuctionListState.loading());
    _cursor = null;
    _hasMore = true;
    state = AsyncValue.data(await _loadFirstPage());
  }

  Future<void> fetchNextPage() async {
    if (!_hasMore) return;

    // Prevent overlapping loads.
    final isAlreadyLoading = state.isLoading;
    if (isAlreadyLoading) return;

    final currentData = state.valueOrNull;
    final List<AuctionEntity> currentItems = currentData?.maybeWhen(
          success: (items, hasMore, isFetchingMore) => items,
          orElse: () => const <AuctionEntity>[],
        ) ??
        const <AuctionEntity>[];

    if (currentData is AuctionListSuccess) {
      state = AsyncValue.data(currentData.copyWith(isFetchingMore: true));
    }

    final repository = ref.read(auctionRepositoryProvider);

    try {
      final AuctionPage page = await repository.fetchAuctionsPage(
        startAfter: _cursor,
        limit: _pageSize,
      );

      final merged = <AuctionEntity>[...currentItems, ...page.items];

      _cursor = page.lastDoc;
      _hasMore = page.hasMore;

      state = AsyncValue.data(
        AuctionListState.success(
          items: List.unmodifiable(merged),
          hasMore: _hasMore,
          isFetchingMore: false,
        ),
      );
    } catch (e) {
      // Keep current list on screen, but stop the loading-more flag.
      state = AsyncValue.data(
        AuctionListState.success(
          items: List.unmodifiable(currentItems),
          hasMore: _hasMore,
          isFetchingMore: false,
        ),
      );
    }
  }
}
