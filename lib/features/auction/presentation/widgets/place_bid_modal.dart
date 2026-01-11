import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../../../../core/i18n/language_provider.dart';
import '../../../../core/i18n/lotex_i18n.dart';
import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/human_error.dart';
import '../../../../core/theme/lotex_ui_tokens.dart';
import '../../../../core/widgets/lotex_modal.dart';
import 'package:lotex/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:lotex/features/chat/presentation/pages/chat_conversation_screen.dart';
import 'package:lotex/features/chat/presentation/providers/chat_providers.dart';
import '../../domain/entities/auction_entity.dart';
import '../providers/place_bid_controller.dart';

Future<void> showPlaceBidModal({
  required BuildContext context,
  required WidgetRef ref,
  required AuctionEntity auction,
}) async {
  final parentContext = context;
  final lang = ref.read(lotexLanguageProvider);
  final controller = TextEditingController();

  final minBid =
      (auction.currentPrice <= 0 ? auction.startPrice : auction.currentPrice) +
          1;
  controller.text = minBid.toStringAsFixed(0);

  await showLotexModal<void>(
    context: parentContext,
    title: LotexI18n.tr(lang, 'placeBid'),
    child: Consumer(
      builder: (modalContext, ref, _) {
        final state = ref.watch(placeBidControllerProvider);

        Future<void> openChatWithSeller() async {
          final user = ref.read(currentUserProvider);
          if (user == null) return;
          final sellerId = auction.sellerId;
          if (sellerId.trim().isEmpty) {
            // ignore: avoid_print
            print('REAL ERROR: sellerId is empty for auctionId=${auction.id}');
            return;
          }
          if (sellerId == user.uid) return;

          final repo = ref.read(chatRepositoryProvider);
          final dialogId = await repo.ensureAuctionDialog(
            auctionId: auction.id,
            buyerId: user.uid,
            sellerId: sellerId,
            title: auction.title,
          );
          if (!parentContext.mounted) return;
          Navigator.push(
            parentContext,
            MaterialPageRoute(
              builder: (_) => ChatConversationScreen(
                dialogId: dialogId,
                role: 'buyer',
                title: auction.title,
              ),
            ),
          );
        }

        ref.listen<AsyncValue<void>>(placeBidControllerProvider, (prev, next) {
          next.whenOrNull(
            data: (_) {
              if (Navigator.of(modalContext).canPop()) {
                Navigator.of(modalContext).pop();
              }
              // Navigate after the modal is closed.
              Future.microtask(() async {
                try {
                  await openChatWithSeller();
                } catch (e, st) {
                  // ignore: avoid_print
                  print('REAL ERROR: $e');
                  // ignore: avoid_print
                  print('REAL STACK: $st');
                }
              });
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
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: LotexUiColors.slate400),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withAlpha((0.06 * 255).round()),
                hintText: LotexI18n.formatCurrency(minBid, lang),
                hintStyle: const TextStyle(color: LotexUiColors.slate500),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: Colors.white.withAlpha((0.08 * 255).round())),
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
                  final raw = state.error is AsyncError
                      ? (state.error as AsyncError).error
                      : state.error!;

                  final Failure failure = FailureMapper.from(raw);
                  final details = failure.message(lang).trim().isNotEmpty
                      ? failure.message(lang)
                      : humanError(raw);
                  return Text(
                    details,
                    style:
                        const TextStyle(color: Colors.redAccent, fontSize: 12),
                  );
                },
              ),
            const SizedBox(height: 14),
            SizedBox(
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [LotexUiColors.violet600, LotexUiColors.blue600]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton(
                  onPressed: state.isLoading
                      ? null
                      : () async {
                          final parsed = double.tryParse(
                              controller.text.trim().replaceAll(' ', ''));
                          if (parsed == null) return;
                          if (parsed < minBid) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${LotexI18n.tr(lang, 'minPrefix')}: ${LotexI18n.formatCurrency(minBid, lang)}'),
                              ),
                            );
                            return;
                          }
                          await ref
                              .read(placeBidControllerProvider.notifier)
                              .placeBid(
                                auctionId: auction.id,
                                bidAmount: parsed,
                              );
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
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
            style: const TextStyle(
                fontSize: 12,
                color: LotexUiColors.slate400,
                fontWeight: FontWeight.w700),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
              fontSize: 12, color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
