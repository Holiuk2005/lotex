import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <--- ДОДАЙ
import 'dart:convert';
import 'package:intl/intl.dart';
// import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart'; //
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/auction_entity.dart'; //
import '../providers/place_bid_controller.dart'; // <--- ДОДАЙ
import '../widgets/lotex_input.dart'; // <--- ДОДАЙ (сподіваюсь, цей файл є)

// 2. Змініть StatelessWidget на ConsumerWidget
class AuctionDetailsScreen extends ConsumerWidget { // <--- ЗМІНИ
  final AuctionEntity auction;

  const AuctionDetailsScreen({super.key, required this.auction});

  // 👇 ДОДАЙТЕ ЦЕЙ МЕТОД
  void _showBidSheet(BuildContext context, WidgetRef ref) {
    final TextEditingController bidController = TextEditingController(
      text: (auction.currentPrice + 100).toStringAsFixed(0) // Рекомендована ставка +100
    );
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets.copyWith(top: 0),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Зробити ставку", style: AppTextStyles.h2),
                  const SizedBox(height: 16),
                  
                  LotexInput(
                    label: "Ваша ставка (мінімум ${auction.currentPrice + 1})",
                    hint: "Введіть суму",
                    controller: bidController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Введіть суму';
                      final bid = double.tryParse(value);
                      if (bid == null || bid <= auction.currentPrice) {
                        return 'Сума має бути більшою за ${auction.currentPrice}';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  Consumer(
                    builder: (context, ref, child) {
                      final state = ref.watch(placeBidControllerProvider);
                      final isLoading = state.isLoading;
                      
                      return ElevatedButton(
                        onPressed: isLoading ? null : () {
                          if (formKey.currentState!.validate()) {
                            final bidAmount = double.parse(bidController.text);
                            ref.read(placeBidControllerProvider.notifier).placeBid(
                              auctionId: auction.id,
                              bidAmount: bidAmount,
                            );
                          }
                        },
                        child: isLoading
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("ПІДТВЕРДИТИ СТАВКУ"),
                      );
                    }
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) { // <--- ЗМІНИ
    // 3. Слухаємо контролер на помилки/успіх (UI Feedback)
    ref.listen<AsyncValue<void>>(placeBidControllerProvider, (prev, next) {
      next.when(
        data: (_) {
          if (prev!.isLoading) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ставка прийнята!'), backgroundColor: AppColors.success)
            );
            Navigator.of(context).pop(); // Закриваємо Bottom Sheet
          }
        },
        error: (e, st) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Помилка ставки: ${e.toString()}'), backgroundColor: AppColors.error)
          );
        },
        loading: () {},
      );
    });

    final priceFormat = NumberFormat.currency(locale: 'uk_UA', symbol: '₴', decimalDigits: 0);

    return Scaffold(
      // ... (body, appBar залишаються тими самими)
      body: SingleChildScrollView(
        // ...
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 350,
              width: double.infinity,
              color: Colors.grey[200],
              child: (auction.imageBase64 != null && auction.imageBase64!.isNotEmpty)
                  ? Image.memory(base64Decode(auction.imageBase64!), fit: BoxFit.cover)
                  : (auction.imageUrl.isNotEmpty
                      ? Image.network(auction.imageUrl, fit: BoxFit.cover)
                      : const Center(child: Icon(Icons.image, size: 64, color: Colors.grey))),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(auction.title, style: AppTextStyles.h2),
                  const SizedBox(height: 8),
                  // 🔥 Тут відображається ЦІНА, яка оновиться автоматично, коли 
                  // головний StreamProvider її змінить!
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
                  const SizedBox(height: 100), // Відступ для скролу
                ],
              ),
            ),
          ],
        ),
      ),
      
      // 4. Підключення кнопки
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: const Color.fromRGBO(0,0,0,0.1), blurRadius: 10)],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () => _showBidSheet(context, ref), // <--- ВИКЛИК ШІТУ
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent500),
            child: const Text("ЗРОБИТИ СТАВКУ"),
          ),
        ),
      ),
    );
  }
}