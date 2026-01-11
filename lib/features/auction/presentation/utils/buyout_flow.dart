import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:lotex/core/i18n/language_provider.dart';
import 'package:lotex/core/i18n/lotex_i18n.dart';
import 'package:lotex/core/utils/human_error.dart';
import 'package:lotex/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:lotex/features/auction/data/repositories/auction_repository.dart';
import 'package:lotex/features/auction/domain/entities/auction_entity.dart';
import 'package:lotex/features/chat/presentation/pages/chat_conversation_screen.dart';
import 'package:lotex/features/chat/presentation/providers/chat_providers.dart';

String _shortId(String id) {
  if (id.isEmpty) return '—';
  final head = id.length >= 6 ? id.substring(0, 6) : id;
  return '$head…';
}

Future<void> runBuyoutFlow({
  required BuildContext context,
  required WidgetRef ref,
  required AuctionEntity auction,
}) async {
  // Try sync user first, then fall back to latest auth state (prevents false-null on cold start).
  final user = ref.read(currentUserProvider) ?? ref.read(authStateChangesProvider).value;
  final lang = ref.read(lotexLanguageProvider);

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(LotexI18n.tr(lang, 'authRequired'))),
    );
    return; // stay on page; do not redirect away from buyout flow
  }

  final buyout = auction.buyoutPrice;
  if (buyout == null || buyout <= 0) return;

  final priceFormat = NumberFormat.decimalPattern('uk_UA');
  final priceText = priceFormat.format(buyout);

  final ok = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(LotexI18n.tr(lang, 'buyoutConfirmTitle')),
        content: Text(
          LotexI18n.tr(lang, 'buyoutConfirmBody').replaceFirst('{price}', priceText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(LotexI18n.tr(lang, 'cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(LotexI18n.tr(lang, 'buyoutAction')),
          ),
        ],
      );
    },
  );

  if (ok != true) return;

  try {
    await ref.read(auctionRepositoryProvider).buyoutAuction(
          auctionId: auction.id,
          buyerId: user.uid,
          buyerName: (user.displayName?.trim().isNotEmpty ?? false) ? user.displayName!.trim() : _shortId(user.uid),
        );

    if (!context.mounted) return;
    // After a successful buyout, open chat with the seller.
    // (Shipping can still be accessed from the lot screen if needed.)
    try {
      final sellerId = auction.sellerId;
      if (sellerId.trim().isNotEmpty && sellerId != user.uid) {
        final repo = ref.read(chatRepositoryProvider);
        final dialogId = await repo.ensureAuctionDialog(
          auctionId: auction.id,
          buyerId: user.uid,
          sellerId: sellerId,
          title: auction.title,
        );
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatConversationScreen(dialogId: dialogId, role: 'buyer', title: auction.title),
          ),
        );
        return;
      }
    } catch (e, st) {
      // ignore: avoid_print
      print('REAL ERROR: $e');
      // ignore: avoid_print
      print('REAL STACK: $st');
    }

    context.push('/shipping/${auction.id}');
  } catch (e) {
    // ignore: avoid_print
    print('REAL ERROR: $e');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          LotexI18n.tr(lang, 'errorWithDetails').replaceFirst('{details}', humanError(e)),
        ),
      ),
    );
  }
}
