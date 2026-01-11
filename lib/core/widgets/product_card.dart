import 'package:flutter/material.dart';
import '../../features/home/product_details_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

class ProductCard extends StatelessWidget {
  final String heroTag;
  final String title;
  final String price;

  const ProductCard({
    super.key,
    this.heroTag = 'product_1',
    this.title = 'iPhone 13 Pro Max',
    this.price = '25 000 ₴',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (_, __, ___) => ProductDetailsScreen(title: title, heroTag: heroTag),
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Hero
            Hero(
              tag: heroTag,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Container(color: Theme.of(context).colorScheme.surface),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.h2.copyWith(color: Theme.of(context).textTheme.titleLarge?.color)),
                  const SizedBox(height: 8),
                  Text(price, style: AppTextStyles.priceLarge),
                  const SizedBox(height: 4),
                  Text('Київ • 2 години тому', style: AppTextStyles.caption.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
