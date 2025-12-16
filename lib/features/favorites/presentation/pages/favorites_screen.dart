import 'package:flutter/material.dart';
import 'package:lotex/core/theme/app_colors.dart';
import 'package:lotex/core/theme/app_text_styles.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Обране'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: AppColors.primary500),
            const SizedBox(height: 16),
            Text('У вас поки що немає обраних лотів', style: AppTextStyles.bodyRegular),
          ],
        ),
      ),
    );
  }
}
