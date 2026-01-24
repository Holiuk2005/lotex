import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotex/core/theme/lotex_ui_tokens.dart';
import 'package:lotex/core/widgets/lotex_app_bar.dart';
import 'package:lotex/core/widgets/lotex_background.dart';
import 'package:lotex/core/i18n/language_provider.dart';
import 'package:lotex/core/i18n/lotex_i18n.dart';
import 'package:lotex/core/utils/human_error.dart';
import 'package:lotex/core/widgets/empty_state_widget.dart';
import 'package:lotex/features/auction/presentation/providers/auction_list_provider.dart';
import 'package:lotex/features/auction/presentation/utils/buyout_flow.dart';
import 'package:lotex/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:lotex/features/auction/presentation/widgets/lotex_auction_grid_v2.dart';
import 'package:go_router/go_router.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(lotexLanguageProvider);
    final favoriteIds = ref.watch(favoritesProvider);
    final auctionsAsync = ref.watch(auctionListProvider);

    return Scaffold(
      appBar: LotexAppBar(titleText: LotexI18n.tr(lang, 'favorites'), showDefaultActions: false),
      body: Stack(
        children: [
          const LotexBackground(),
          Positioned.fill(
            child: auctionsAsync.when(
              data: (auctions) {
                final items = auctions.where((a) => favoriteIds.contains(a.id)).toList(growable: false);
                if (items.isEmpty) {
                  return EmptyStateWidget(
                    title: LotexI18n.tr(lang, 'favoritesEmpty'),
                    icon: Icons.favorite_border,
                    buttonText: LotexI18n.tr(lang, 'browse'),
                    onButtonPressed: () => context.go('/home'),
                  );
                }

                final width = MediaQuery.sizeOf(context).width;
                final pad = EdgeInsets.all(width >= 768 ? 32 : 16);

                return Padding(
                  padding: pad,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LotexI18n.tr(lang, 'saved'),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        LotexI18n.tr(lang, 'savedDescription'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: LotexUiColors.slate400,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: LotexAuctionGridV2(
                          items: items,
                          onSelect: (auction) {
                            context.push('/auction', extra: auction);
                          },
                          onBuyout: (auction) => runBuyoutFlow(context: context, ref: ref, auction: auction),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: LotexUiColors.violet500),
              ),
              error: (e, st) => Center(
                child: Text(
                  LotexI18n.tr(lang, 'errorWithDetails').replaceFirst('{details}', humanError(e)),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: LotexUiColors.slate400),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
