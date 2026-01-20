import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lotex/core/i18n/lotex_i18n.dart';
import 'package:lotex/core/theme/lotex_ui_tokens.dart';
import 'package:lotex/core/utils/human_error.dart';
import 'package:lotex/core/widgets/lotex_app_bar.dart';
import 'package:lotex/features/auction/domain/entities/auction_entity.dart';

class MyLotsScreen extends StatelessWidget {
  const MyLotsScreen({super.key});

  LotexLanguage _langOf(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'uk'
        ? LotexLanguage.uk
        : LotexLanguage.en;
  }

  @override
  Widget build(BuildContext context) {
    final lang = _langOf(context);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    final muted = Theme.of(context).brightness == Brightness.dark
        ? LotexUiColors.darkMuted
        : LotexUiColors.lightMuted;

    return Scaffold(
      appBar: LotexAppBar(
        showBack: true,
        showDesktopSearch: false,
        titleText: LotexI18n.tr(lang, 'myLots'),
      ),
      body: uid == null
          ? Center(
              child: Text(
                LotexI18n.tr(lang, 'authRequired'),
                style: LotexUiTextStyles.bodyRegular,
              ),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('auctions')
                  .where('sellerId', isEqualTo: uid)
                  .orderBy('createdAt', descending: true)
                  .limit(100)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      LotexI18n.tr(lang, 'errorWithDetails').replaceFirst(
                            '{details}',
                            humanError(snapshot.error ?? Exception('Unknown error')),
                          ),
                      style: LotexUiTextStyles.bodyRegular,
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: LotexUiColors.violet600),
                  );
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      LotexI18n.tr(lang, 'noAuctionsFound'),
                      style: LotexUiTextStyles.bodyRegular,
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final auction = AuctionEntity.fromDocument(doc);

                    return Material(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => context.push('/auction', extra: auction),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: LotexUiColors.violet500.withAlpha((0.15 * 255).round()),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.gavel_rounded, color: LotexUiColors.violet600),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      auction.title,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      LotexI18n.formatCurrency(
                                        auction.currentPrice,
                                        lang,
                                        currency: auction.currency,
                                      ),
                                      style: LotexUiTextStyles.bodyRegular.copyWith(color: muted),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: muted),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
