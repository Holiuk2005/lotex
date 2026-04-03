import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/marketplace_item_entity.dart';
import '../../../../core/widgets/lotex_app_bar.dart';
import '../../../../core/widgets/lotex_background.dart';
import '../../../../core/theme/lotex_ui_tokens.dart';
import '../../../../features/auth/presentation/providers/auth_state_provider.dart';
import '../providers/marketplace_providers.dart';
import '../../../../core/widgets/app_button.dart';

class MarketplaceItemDetailsScreen extends ConsumerStatefulWidget {
  final MarketplaceItemEntity item;
  const MarketplaceItemDetailsScreen({super.key, required this.item});

  @override
  ConsumerState<MarketplaceItemDetailsScreen> createState() => _MarketplaceItemDetailsScreenState();
}

class _MarketplaceItemDetailsScreenState extends ConsumerState<MarketplaceItemDetailsScreen> {
  bool _isPurchasing = false;

  void _purchaseItem() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      context.push('/login');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Підтвердження покупки'),
        content: Text('Ви впевнені, що хочете придбати цей товар за ${widget.item.price} ${widget.item.currency}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Скасувати')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Придбати')),
        ],
      )
    );

    if (confirm != true) return;

    setState(() => _isPurchasing = true);
    try {
      await ref.read(marketplaceRepositoryProvider).buyItem(
        itemId: widget.item.id,
        buyerId: user.uid,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Покупка успішна! Очікуйте на доставку')));
      
      // Navigate to shipping checkout (mock flow) or just pop back
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Помилка: $e')));
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSold = widget.item.status == 'sold';
    final user = ref.watch(currentUserProvider);
    final isOwner = user?.uid == widget.item.sellerId;

    return Scaffold(
      appBar: const LotexAppBar(
        titleText: 'Товар',
        showDefaultActions: false,
      ),
      body: Stack(
        children: [
          const LotexBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: widget.item.imageUrl,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.item.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.item.price} ${widget.item.currency}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: LotexUiColors.violet400),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.item.description,
                  style: const TextStyle(fontSize: 16, color: LotexUiColors.slate400),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: isSold
          ? const AppButton.primary(label: 'Продано', onPressed: null)
          : isOwner 
            ? const AppButton.primary(label: 'Ваш товар', onPressed: null)
            : AppButton.primary(
                label: _isPurchasing ? 'Обробка...' : 'Придбати',
                onPressed: _isPurchasing ? null : _purchaseItem,
              ),
      ),
    );
  }
}
