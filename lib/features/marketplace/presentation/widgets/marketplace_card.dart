import 'package:flutter/material.dart';
import '../../domain/entities/marketplace_item_entity.dart';
import '../../../../core/theme/lotex_ui_tokens.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MarketplaceCard extends StatelessWidget {
  final MarketplaceItemEntity item;
  final VoidCallback onTap;

  const MarketplaceCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha((0.05 * 255).round()),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withAlpha((0.10 * 255).round())),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.black12),
                    errorWidget: (context, url, err) => Container(color: Colors.black12, child: const Icon(Icons.image)),
                  ),
                  Positioned(
                    top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: LotexUiColors.violet500,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text('Маркетплейс', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  if (item.status == 'sold')
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: Text('ПРОДАНО', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text('${item.price} ${item.currency}', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF34D399), fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
