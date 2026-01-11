import 'package:flutter/material.dart';

import '../../domain/entities/auction_entity.dart';
import 'lotex_auction_card_v2.dart';

class LotexAuctionGridV2 extends StatelessWidget {
  final List<AuctionEntity> items;
  final ValueChanged<AuctionEntity> onSelect;
  final ValueChanged<AuctionEntity>? onBuyout;

  const LotexAuctionGridV2({
    super.key,
    required this.items,
    required this.onSelect,
    this.onBuyout,
  });

  int _crossAxisCount(double width) {
    if (width >= 1280) return 3; // xl
    if (width >= 768) return 2; // md
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final count = _crossAxisCount(width);

    // GridView forces all tiles in a row to have the same height.
    // On mobile (1 column) we want the card height to grow/shrink with its content.
    if (count == 1) {
      return ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 24),
        itemBuilder: (context, i) {
          final a = items[i];
          return LotexAuctionCardV2(
            auction: a,
            onTap: () => onSelect(a),
            onBuyout: () => (onBuyout ?? onSelect)(a),
          );
        },
      );
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        // Taller tiles to fit the card content without RenderFlex overflow.
        childAspectRatio: count == 2 ? 0.58 : 0.55,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final a = items[i];
        return LotexAuctionCardV2(
          auction: a,
          onTap: () => onSelect(a),
          onBuyout: () => (onBuyout ?? onSelect)(a),
        );
      },
    );
  }
}
