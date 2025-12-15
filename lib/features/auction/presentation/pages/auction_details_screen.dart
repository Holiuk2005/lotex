import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/auction_entity.dart';

class AuctionDetailsScreen extends StatelessWidget {
  final AuctionEntity auction;

  const AuctionDetailsScreen({super.key, required this.auction});

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat.currency(locale: 'uk_UA', symbol: '₴', decimalDigits: 0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 350,
              width: double.infinity,
              color: Colors.grey[200],
              child: auction.imageUrl.isNotEmpty
                  ? Image.network(auction.imageUrl, fit: BoxFit.cover)
                  : const Center(child: Icon(Icons.image, size: 64, color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(auction.title, style: AppTextStyles.h2),
                  const SizedBox(height: 8),
                  Text(
                    priceFormat.format(auction.currentPrice),
                    style: AppTextStyles.priceLarge.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text("Опис", style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Text(auction.description, style: AppTextStyles.bodyRegular),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {}, // Тут буде логіка ставки
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent500),
            child: const Text("ЗРОБИТИ СТАВКУ"),
          ),
        ),
      ),
    );
  }
}