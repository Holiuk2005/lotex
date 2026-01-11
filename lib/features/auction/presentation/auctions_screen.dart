import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotex/core/utils/human_error.dart';
import 'providers/auction_pagination_controller.dart';
import 'state/auction_list_state.dart';
import 'widgets/auction_card.dart';

class AuctionsScreen extends ConsumerWidget {
  const AuctionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auctions = ref.watch(auctionPaginationControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Auctions')),
      body: auctions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(humanError(e))),
        data: (state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error) => Center(child: Text(humanError(error))),
            success: (items, hasMore, isFetchingMore) {
              if (items.isEmpty) {
                return const Center(child: Text('No auctions yet'));
              }

              Future<void> onRefresh() async {
                await ref
                    .read(auctionPaginationControllerProvider.notifier)
                    .refresh();
              }

              return RefreshIndicator(
                onRefresh: onRefresh,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (!hasMore || isFetchingMore) return false;
                    final threshold = n.metrics.maxScrollExtent - 200;
                    if (n.metrics.pixels >= threshold) {
                      ref
                          .read(auctionPaginationControllerProvider.notifier)
                          .fetchNextPage();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    itemCount: items.length + (hasMore ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i >= items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return AuctionCard(
                        auction: items[i],
                        onTap: () {
                          // Реализовать переход к деталям аукциона позже.
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
