import 'dart:math' as math;
import 'dart:ui';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/language_provider.dart';
import '../../../../core/i18n/lotex_i18n.dart';
import '../../../../core/theme/lotex_ui_tokens.dart';
import '../../../../core/utils/base64_image_cache.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../domain/entities/auction_entity.dart';
import 'auction_timer.dart';

class LotexAuctionCardV2 extends ConsumerStatefulWidget {
  final AuctionEntity auction;
  final VoidCallback onTap;
  final VoidCallback? onPlaceBid;
  final VoidCallback? onBuyout;

  const LotexAuctionCardV2({
    super.key,
    required this.auction,
    required this.onTap,
    this.onPlaceBid,
    this.onBuyout,
  });

  @override
  ConsumerState<LotexAuctionCardV2> createState() => _LotexAuctionCardV2State();
}

class _LotexAuctionCardV2State extends ConsumerState<LotexAuctionCardV2> {
  bool _hovered = false;

  Widget _fallbackImage() {
    return Container(
      color: LotexUiColors.slate900,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: Colors.white.withAlpha((0.60 * 255).round()),
          size: 44,
        ),
      ),
    );
  }

  double _progressFromTimeLeft(Duration timeLeft) {
    // Design wants a 0..100 progress ring. We don't have start time, so we
    // approximate over 24h window.
    const total = Duration(hours: 24);
    final clamped = timeLeft.isNegative ? Duration.zero : (timeLeft > total ? total : timeLeft);
    final ratio = 1.0 - (clamped.inSeconds / total.inSeconds);
    return (ratio * 100).clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(lotexLanguageProvider);
    final auction = widget.auction;
    final isFavorite = ref.watch(favoritesProvider.select((s) => s.contains(auction.id)));

    final title = auction.title;
    final artist = auction.sellerId.isEmpty ? LotexI18n.tr(lang, 'unknown') : auction.sellerId;

    Uint8List? base64Bytes;
    if (auction.imageBase64 != null && auction.imageBase64!.trim().isNotEmpty) {
      base64Bytes = Base64ImageCache.decode(
        auction.imageBase64!,
        cacheKey: 'auction:${auction.id}',
      );
    }

    final Widget imageWidget;
    if (auction.imageUrl.trim().isNotEmpty) {
      imageWidget = Image.network(
        auction.imageUrl,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
        errorBuilder: (_, __, ___) => _fallbackImage(),
      );
    } else if (base64Bytes != null) {
      imageWidget = Image.memory(
        base64Bytes,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _fallbackImage(),
      );
    } else {
      imageWidget = _fallbackImage();
    }

    final showButton = _hovered || MediaQuery.sizeOf(context).width < 768;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          offset: _hovered ? const Offset(0, -0.02) : Offset.zero,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            scale: _hovered ? 1.02 : 1.0,
            child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _hovered
                    ? LotexUiColors.purple500.withAlpha((0.30 * 255).round())
                    : Colors.white.withAlpha((0.10 * 255).round()),
              ),
              boxShadow: [
                BoxShadow(
                  color: _hovered
                      ? LotexUiColors.purple500.withAlpha((0.20 * 255).round())
                      : Colors.black.withAlpha((0.30 * 255).round()),
                  blurRadius: 24,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  color: Colors.white.withAlpha((0.05 * 255).round()),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;

                      // Ideal image height from the original 4:3 AspectRatio.
                      final idealImageHeight = w * 3 / 4;

                      // If the parent constrains height (common in Grid), shrink the image
                      // to ensure the content below fits and we never overflow.
                      // Note: details area includes padding, title/artist, price/timer row,
                      // and the CTA button slot (which is always laid out even when opacity=0).
                      final reservedForDetails = showButton ? 308.0 : 264.0;
                      final minImageHeight = (h.isFinite && h < 520) ? 120.0 : 160.0;
                      final isTight = h.isFinite && h < (idealImageHeight + reservedForDetails);
                      final padding = isTight ? 16.0 : 20.0;
                      final gap16 = isTight ? 12.0 : 16.0;

                      double imageHeight = idealImageHeight;
                      if (h.isFinite) {
                        final maxImageHeight = math.max(minImageHeight, h - reservedForDetails);
                        imageHeight = math.min(idealImageHeight, maxImageHeight);
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: imageHeight,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                AnimatedScale(
                                  scale: _hovered ? 1.1 : 1.0,
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeOut,
                                  child: imageWidget,
                                ),
                                // Overlay gradient
                                Opacity(
                                  opacity: 0.60,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          LotexUiColors.slate950.withAlpha((0.80 * 255).round()),
                                          Colors.transparent,
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Live badge
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withAlpha((0.40 * 255).round()),
                                          border: Border.all(
                                            color: Colors.white.withAlpha((0.10 * 255).round()),
                                          ),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(
                                              width: 8,
                                              height: 8,
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFEF4444),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              LotexI18n.tr(lang, 'live'),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(padding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          height: 1.2,
                                          color: _hovered ? LotexUiColors.purple300 : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        artist,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: LotexUiColors.slate400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  onPressed: () => ref.read(favoritesProvider.notifier).toggle(auction.id),
                                  icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                                  color: isFavorite ? LotexUiColors.neonOrange : LotexUiColors.slate400,
                                  splashRadius: 20,
                                ),
                              ],
                            ),
                            SizedBox(height: gap16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        LotexI18n.tr(lang, 'currentBid').toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.2,
                                          color: LotexUiColors.slate400,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.trending_up, size: 16, color: LotexUiColors.neonGreen),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              LotexI18n.formatCurrency(auction.currentPrice, lang),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 120,
                                  child: AuctionTimer(
                                    endTime: auction.endDate,
                                    builder: (context, timeLeft) {
                                      final progress = _progressFromTimeLeft(timeLeft);
                                      return _TimerPill(
                                        lang: lang,
                                        timeLeft: timeLeft,
                                        progress: progress,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: gap16),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SizeTransition(
                                    sizeFactor: animation,
                                    axis: Axis.vertical,
                                    axisAlignment: -1,
                                    child: child,
                                  ),
                                );
                              },
                              child: showButton
                                  ? SizedBox(
                                      key: const ValueKey('cta'),
                                      height: 44,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [LotexUiColors.purple600, LotexUiColors.blue600],
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: LotexUiColors.purple500.withAlpha((0.25 * 255).round()),
                                                    blurRadius: 18,
                                                    offset: const Offset(0, 10),
                                                  ),
                                                ],
                                              ),
                                              child: TextButton(
                                                onPressed: widget.onPlaceBid ?? widget.onTap,
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                ),
                                                child: Text(
                                                  LotexI18n.tr(lang, 'openLot'),
                                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (widget.auction.buyoutPrice != null && widget.auction.buyoutPrice! > 0)
                                            ...[const SizedBox(width: 8)],
                                          if (widget.auction.buyoutPrice != null && widget.auction.buyoutPrice! > 0)
                                            Expanded(
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withAlpha((0.10 * 255).round()),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Colors.white.withAlpha((0.20 * 255).round()),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withAlpha((0.15 * 255).round()),
                                                      blurRadius: 12,
                                                      offset: const Offset(0, 8),
                                                    ),
                                                  ],
                                                ),
                                                child: TextButton(
                                                  onPressed: widget.onBuyout ?? widget.onTap,
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                  ),
                                                  child: Text(
                                                    LotexI18n.tr(lang, 'buyoutAction'),
                                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox(key: ValueKey('cta-empty')),
                            ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerPill extends StatelessWidget {
  final LotexLanguage lang;
  final Duration timeLeft;
  final double progress;

  const _TimerPill({required this.lang, required this.timeLeft, required this.progress});

  @override
  Widget build(BuildContext context) {
    String text;
    if (timeLeft.isNegative) {
      text = LotexI18n.tr(lang, 'endedStatus');
    } else {
      final h = timeLeft.inHours;
      final m = timeLeft.inMinutes.remainder(60);
      final hs = LotexI18n.tr(lang, 'hoursShort');
      final ms = LotexI18n.tr(lang, 'minutesShort');
      text = '$h$hs $m$ms';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.05 * 255).round()),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withAlpha((0.05 * 255).round())),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: 34,
            height: 34,
            child: _ProgressRing(progress: progress / 100),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    LotexI18n.tr(lang, 'endsIn'),
                    style: const TextStyle(fontSize: 12, color: LotexUiColors.slate400),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatefulWidget {
  final double progress; // 0..1

  const _ProgressRing({required this.progress});

  @override
  State<_ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<_ProgressRing> {
  double _from = 0.0;
  double _to = 0.0;

  @override
  void initState() {
    super.initState();
    final p = widget.progress.clamp(0.0, 1.0);
    _from = p;
    _to = p;
  }

  @override
  void didUpdateWidget(covariant _ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.progress.clamp(0.0, 1.0);
    _from = _to;
    _to = next;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const CircularProgressIndicator(
            value: 1,
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(LotexUiColors.slate700),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: _from, end: _to),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOut,
            builder: (context, value, _) {
              return CircularProgressIndicator(
                value: value,
                strokeWidth: 3,
                valueColor: const AlwaysStoppedAnimation<Color>(LotexUiColors.purple500),
                backgroundColor: Colors.transparent,
              );
            },
          ),
          const Icon(Icons.access_time, size: 16, color: Colors.white),
        ],
      ),
    );
  }
}
