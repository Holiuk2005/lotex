import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotex/core/i18n/language_provider.dart';
import 'package:lotex/core/i18n/lotex_i18n.dart';
import 'package:lotex/core/theme/lotex_ui_tokens.dart';
import 'package:lotex/features/auction/domain/entities/auction_entity.dart';
import 'package:lotex/features/favorites/presentation/providers/favorites_provider.dart';

import 'auction_timer.dart';

class AuctionCard extends ConsumerWidget {
  final AuctionEntity auction;
  final VoidCallback onTap;

  const AuctionCard({
    super.key,
    required this.auction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(lotexLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isFavorite = ref.watch(favoritesProvider.select((s) => s.contains(auction.id)));

    final surface = isDark ? Colors.white.withAlpha((0.05 * 255).round()) : Theme.of(context).colorScheme.surface;
    final border = isDark
        ? Colors.white.withAlpha((0.10 * 255).round())
        : Theme.of(context).dividerColor.withAlpha((0.8 * 255).round());

    final titleColor = isDark ? Colors.white : Theme.of(context).colorScheme.onSurface;
    final muted = isDark ? LotexUiColors.slate400 : LotexUiColors.slate500;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: border),
          boxShadow: isDark ? null : const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.06),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (auction.imageBase64 != null && auction.imageBase64!.isNotEmpty)
                    Image.memory(convert.base64Decode(auction.imageBase64!), fit: BoxFit.cover)
                  else if (auction.imageUrl.isNotEmpty)
                    Image.network(
                      auction.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: isDark ? LotexUiColors.slate900 : LotexUiColors.lightBackground,
                          child: Icon(Icons.image, size: 42, color: muted),
                        );
                      },
                    )
                  else
                    Container(
                      color: isDark ? LotexUiColors.slate900 : LotexUiColors.lightBackground,
                      child: Icon(Icons.image, size: 42, color: muted),
                    ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          LotexUiColors.slate950.withAlpha((0.80 * 255).round()),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: AuctionTimer(
                      endTime: auction.endDate,
                      builder: (context, timeLeft) {
                        final isLive = !timeLeft.isNegative && timeLeft != Duration.zero;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha((0.40 * 255).round()),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white.withAlpha((0.10 * 255).round())),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isLive ? const Color(0xFFEF4444) : LotexUiColors.slate500,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isLive ? 'Live' : 'Ended',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auction.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: titleColor),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ставок: ${auction.bidCount}',
                              style: TextStyle(fontSize: 12, color: muted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => ref.read(favoritesProvider.notifier).toggle(auction.id),
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? LotexUiColors.neonOrange : muted,
                        ),
                        tooltip: 'В обране',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current Bid', style: TextStyle(fontSize: 11, color: muted, letterSpacing: 0.4)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.trending_up, size: 16, color: Color(0xFF10B981)),
                              const SizedBox(width: 6),
                              Text(
                                LotexI18n.formatCurrency(
                                  auction.currentPrice,
                                  lang,
                                  currency: auction.currency,
                                ),
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: titleColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          AuctionTimer(
                            endTime: auction.endDate,
                            builder: (context, timeLeft) {
                              final isUrgent = timeLeft.inMinutes < 5 && timeLeft != Duration.zero;
                              final isEnded = timeLeft == Duration.zero;

                              final String timerText;
                              if (isEnded) {
                                timerText = 'Завершено';
                              } else if (timeLeft.inHours > 24) {
                                timerText = "${timeLeft.inDays} дн.";
                              } else {
                                timerText =
                                    "${timeLeft.inHours}:${(timeLeft.inMinutes % 60).toString().padLeft(2, '0')}";
                              }

                              return Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 16,
                                    color: isUrgent ? LotexUiColors.error : muted,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    timerText,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isUrgent ? LotexUiColors.error : titleColor,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LotexUiGradients.primary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: isDark ? LotexUiShadows.glow : null,
                      ),
                      child: TextButton(
                        onPressed: onTap,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(LotexI18n.tr(lang, 'openLot'), style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}