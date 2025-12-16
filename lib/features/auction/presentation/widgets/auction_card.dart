import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/auction_entity.dart';

class AuctionCard extends StatelessWidget {
  final AuctionEntity auction;
  final VoidCallback onTap;

  const AuctionCard({
    super.key,
    required this.auction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat.currency(locale: 'uk_UA', symbol: '₴', decimalDigits: 0);
    
    final now = DateTime.now();
    final timeLeft = auction.endDate.difference(now);
    final isUrgent = timeLeft.inMinutes < 5 && !timeLeft.isNegative;
    
    String timerText;
    if (timeLeft.isNegative) {
      timerText = "Завершено";
    } else {
      // Форматування HH:MM (якщо більше 24 годин - показуємо дні)
      if (timeLeft.inHours > 24) {
         timerText = "${timeLeft.inDays} дн.";
      } else {
         timerText = "${timeLeft.inHours}:${(timeLeft.inMinutes % 60).toString().padLeft(2, '0')}";
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0,0,0,0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Картинка
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                image: (auction.imageBase64 != null && auction.imageBase64!.isNotEmpty)
                  ? DecorationImage(image: MemoryImage(base64Decode(auction.imageBase64!)), fit: BoxFit.cover)
                  : (auction.imageUrl.isNotEmpty ? DecorationImage(image: NetworkImage(auction.imageUrl), fit: BoxFit.cover) : null),
              ),
              child: (auction.imageBase64 == null || auction.imageBase64!.isEmpty) && auction.imageUrl.isEmpty
                  ? const Center(child: Icon(Icons.image, size: 40, color: Colors.grey))
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          
          Text(auction.title, style: AppTextStyles.h3, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                priceFormat.format(auction.currentPrice),
                style: AppTextStyles.priceLarge,
              ),
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 16, color: isUrgent ? AppColors.error : AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    timerText,
                    style: AppTextStyles.timer.copyWith(
                      color: isUrgent ? AppColors.error : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          ElevatedButton(
            onPressed: onTap, // Перехід на деталі замість зразу ставки
            child: const Text('ЗРОБИТИ СТАВКУ'),
          ),
        ],
      ),
    );
  }
}