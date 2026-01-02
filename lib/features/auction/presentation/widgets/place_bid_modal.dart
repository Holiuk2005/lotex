import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/i18n/language_provider.dart';
import '../../../../core/i18n/lotex_i18n.dart';
import '../../../../core/theme/lotex_ui_tokens.dart';
import '../../../../core/widgets/lotex_modal.dart';
import '../../domain/entities/auction_entity.dart';
import '../providers/place_bid_controller.dart';

Future<void> showPlaceBidModal({
  required BuildContext context,
  required WidgetRef ref,
  required AuctionEntity auction,
}) async {
  final lang = ref.read(lotexLanguageProvider);
  final controller = TextEditingController();

  final minBid = (auction.currentPrice <= 0 ? auction.startPrice : auction.currentPrice) + 1;
  controller.text = minBid.toStringAsFixed(0);

  await showLotexModal<void>(
    context: context,
    title: LotexI18n.tr(lang, 'placeBid'),
    child: Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(placeBidControllerProvider);

        ref.listen<AsyncValue<void>>(placeBidControllerProvider, (prev, next) {
          next.whenOrNull(
            data: (_) {
              if (Navigator.of(context).canPop()) Navigator.of(context).pop();
            },
          );
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _RowLabelValue(
              label: LotexI18n.tr(lang, 'currentBid'),
              value: LotexI18n.formatCurrency(auction.currentPrice, lang),
            ),
            const SizedBox(height: 10),
            _RowLabelValue(
              label: LotexI18n.tr(lang, 'bidIncrement'),
              value: LotexI18n.formatCurrency(1, lang),
            ),
            const SizedBox(height: 16),
            Text(
              LotexI18n.tr(lang, 'yourBid'),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: LotexUiColors.slate400),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withAlpha((0.06 * 255).round()),
                hintText: LotexI18n.formatCurrency(minBid, lang),
                hintStyle: const TextStyle(color: LotexUiColors.slate500),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withAlpha((0.08 * 255).round())),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: LotexUiColors.violet500),
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (state.hasError)
              Builder(
                builder: (context) {
                  final e = state.error!;
                  String details;
                  if (e is AsyncError) {
                    final inner = e.error;
                    if (inner is FirebaseException) {
                      details = inner.message ?? inner.toString();
                    } else {
                      details = inner.toString();
                    }
                  } else if (e is FirebaseException) {
                    details = e.message ?? e.toString();
                  } else {
                    details = e.toString();
                  }
                  if (details.startsWith('Exception: ')) {
                    details = details.substring('Exception: '.length);
                  }
                  return Text(
                    details,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  );
                },
              ),
            const SizedBox(height: 14),
            SizedBox(
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [LotexUiColors.violet600, LotexUiColors.blue600]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton(
                  onPressed: state.isLoading
                      ? null
                      : () async {
                          final parsed = double.tryParse(controller.text.trim().replaceAll(' ', ''));
                          if (parsed == null) return;
                          if (parsed < minBid) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${LotexI18n.tr(lang, 'minPrefix')}: ${LotexI18n.formatCurrency(minBid, lang)}'),
                              ),
                            );
                            return;
                          }
                          await ref.read(placeBidControllerProvider.notifier).placeBid(
                                auctionId: auction.id,
                                bidAmount: parsed,
                              );
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          LotexI18n.tr(lang, 'confirmBid'),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _RowLabelValue extends StatelessWidget {
  final String label;
  final String value;

  const _RowLabelValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: LotexUiColors.slate400, fontWeight: FontWeight.w700),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
