import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auctions_controller.dart';
import 'widgets/auction_card.dart';

class AuctionsScreen extends ConsumerWidget {
  const AuctionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auctions = ref.watch(auctionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Auctions')),
      body: auctions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No auctions yet'));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) => AuctionCard(
              auction: list[i],
              onTap: () {
                // Реализовать переход к деталям аукциона позже.
              },
            ),
          );
        },
      ),
    );
  }
}
