import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ProductDetailsScreen extends StatelessWidget {
  final String heroTag;
  final String title;

  const ProductDetailsScreen({super.key, this.heroTag = 'product_1', this.title = 'iPhone 13 Pro Max'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: heroTag,
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Container(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(title, style: AppTextStyles.h1),
          ),
        ],
      ),
    );
  }
}
