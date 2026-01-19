import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'package:lotex/core/i18n/language_provider.dart';
import 'package:lotex/core/i18n/lotex_i18n.dart';
import 'package:lotex/core/utils/human_error.dart';
import 'package:lotex/core/theme/lotex_ui_tokens.dart';
import 'package:lotex/core/widgets/app_input.dart';
import 'package:lotex/core/widgets/lotex_background.dart';
import 'package:lotex/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:lotex/features/auction/data/repositories/auction_repository.dart';
import 'package:lotex/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:lotex/features/chat/presentation/providers/chat_providers.dart';
import 'package:lotex/features/chat/presentation/pages/chat_conversation_screen.dart';
import '../../domain/entities/auction_entity.dart';
import '../widgets/auction_timer.dart';
import '../providers/place_bid_controller.dart';

class AuctionDetailsScreen extends ConsumerStatefulWidget {
  final AuctionEntity auction;

  const AuctionDetailsScreen({super.key, required this.auction});

  @override
  ConsumerState<AuctionDetailsScreen> createState() => _AuctionDetailsScreenState();
}

class _AuctionDetailsScreenState extends ConsumerState<AuctionDetailsScreen> {
  late final NumberFormat _priceFormat;
  bool _isBidSheetOpen = false;
  bool _didAutoOpenShipping = false;
  int _thumbIndex = 0;
  ProviderSubscription<AsyncValue<void>>? _placeBidSub;

  AuctionEntity get auction => widget.auction;

  @override
  void initState() {
    super.initState();
    _priceFormat = NumberFormat.currency(locale: 'uk_UA', symbol: '₴', decimalDigits: 0);

    _placeBidSub = ref.listenManual<AsyncValue<void>>(
      placeBidControllerProvider,
      (prev, next) {
        final lang = ref.read(lotexLanguageProvider);
        next.when(
          data: (_) {
            if (prev?.isLoading ?? false) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(LotexI18n.tr(lang, 'bidAccepted'))),
              );
              if (_isBidSheetOpen && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }

              // After a successful bid, navigate to the chat with the seller.
              // Do it in a post-frame callback so we don't push during pop/unmount.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _openChatWithSeller();
              });
            }
          },
          error: (e, st) {
            // ignore: avoid_print
            print('REAL ERROR: $e');
            // ignore: avoid_print
            print('REAL STACK: $st');
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  LotexI18n.tr(lang, 'errorWithDetails').replaceFirst('{details}', humanError(e)),
                ),
              ),
            );
          },
          loading: () {},
        );
      },
    );
  }

  @override
  void dispose() {
    _placeBidSub?.close();
    super.dispose();
  }

  String _timeAgoText(LotexLanguage lang, DateTime? createdAt) {
    if (createdAt == null) return '—';
    final diff = DateTime.now().difference(createdAt);
    final safe = diff.isNegative ? Duration.zero : diff;

    final ds = LotexI18n.tr(lang, 'daysShort');
    final hs = LotexI18n.tr(lang, 'hoursShort');
    final ms = LotexI18n.tr(lang, 'minutesShort');
    final ss = LotexI18n.tr(lang, 'secondsShort');
    final ago = LotexI18n.tr(lang, 'ago');

    if (safe.inDays > 0) return '${safe.inDays}$ds $ago';
    if (safe.inHours > 0) return '${safe.inHours}$hs $ago';
    if (safe.inMinutes > 0) return '${safe.inMinutes}$ms $ago';
    return '${safe.inSeconds}$ss $ago';
  }

  String _shortSeller(String sellerId) {
    if (sellerId.isEmpty) return '—';
    final head = sellerId.length >= 6 ? sellerId.substring(0, 6) : sellerId;
    return '$head…';
  }

  String _humanError(Object e) {
    return humanError(e);
  }

  Future<void> _openChatWithSeller() async {
    final user = ref.read(currentUserProvider);
    final lang = ref.read(lotexLanguageProvider);

    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LotexI18n.tr(lang, 'authRequired'))),
      );
      return;
    }

    if (auction.sellerId.isEmpty || user.uid == auction.sellerId) return;

    try {
      final dialogId = await ref.read(chatRepositoryProvider).ensureAuctionDialog(
            auctionId: auction.id,
            buyerId: user.uid,
            sellerId: auction.sellerId,
            title: auction.title,
          );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatConversationScreen(
            dialogId: dialogId,
            role: 'buyer',
            title: auction.title,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LotexI18n.tr(lang, 'errorWithDetails').replaceFirst('{details}', _humanError(e)),
          ),
        ),
      );
    }
  }

  Future<void> _openChatWithBuyer(String buyerId) async {
    final user = ref.read(currentUserProvider);
    final lang = ref.read(lotexLanguageProvider);

    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LotexI18n.tr(lang, 'authRequired'))),
      );
      return;
    }

    if (buyerId.isEmpty || auction.sellerId.isEmpty) return;
    if (user.uid != auction.sellerId) return;
    if (buyerId == user.uid) return;

    try {
      final dialogId = await ref.read(chatRepositoryProvider).ensureAuctionDialog(
            auctionId: auction.id,
            buyerId: buyerId,
            sellerId: user.uid,
            title: auction.title,
          );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatConversationScreen(
            dialogId: dialogId,
            role: 'seller',
            title: auction.title,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LotexI18n.tr(lang, 'errorWithDetails').replaceFirst('{details}', humanError(e)),
          ),
        ),
      );
    }
  }

  Future<void> _confirmBuyout() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      final lang = ref.read(lotexLanguageProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LotexI18n.tr(lang, 'authRequired'))),
      );
      if (!mounted) return;
      context.push('/login');
      return;
    }

    final buyout = auction.buyoutPrice;
    if (buyout == null || buyout <= 0) return;

    final lang = ref.read(lotexLanguageProvider);
    final priceText = _priceFormat.format(buyout);

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

    if (ok != true || !mounted) return;

    try {
      await ref.read(auctionRepositoryProvider).buyoutAuction(
            auctionId: auction.id,
            buyerId: user.uid,
            buyerName: (user.displayName?.trim().isNotEmpty ?? false) ? user.displayName!.trim() : _shortSeller(user.uid),
          );
      if (!mounted) return;
      context.push('/shipping/${auction.id}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LotexI18n.tr(lang, 'errorWithDetails').replaceFirst('{details}', _humanError(e)),
          ),
        ),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final lang = ref.read(lotexLanguageProvider);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(LotexI18n.tr(lang, 'deleteLotConfirmTitle')),
          content: Text(LotexI18n.tr(lang, 'deleteLotConfirmBody')),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: _DialogButtonSecondary(
                    label: LotexI18n.tr(lang, 'cancel'),
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogButtonPrimary(
                    label: LotexI18n.tr(lang, 'delete'),
                    onTap: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (ok != true || !mounted) return;

    try {
      await ref.read(auctionRepositoryProvider).deleteAuction(
            auctionId: auction.id,
            sellerId: user.uid,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LotexI18n.tr(lang, 'lotDeleted'))),
      );
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        context.go('/home');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LotexI18n.tr(lang, 'errorWithDetails').replaceFirst('{details}', _humanError(e)),
          ),
        ),
      );
    }
  }

  ImageProvider? _auctionImageProvider() {
    final base64 = auction.imageBase64;
    if (base64 != null && base64.isNotEmpty) {
      return MemoryImage(base64Decode(base64));
    }
    if (auction.imageUrl.isNotEmpty) {
      return NetworkImage(auction.imageUrl);
    }
    return null;
  }

  Future<void> _showBidSheet() async {
    final TextEditingController bidController = TextEditingController(
      text: (auction.currentPrice + 100).toStringAsFixed(0),
    );
    final lang = ref.read(lotexLanguageProvider);
    final formKey = GlobalKey<FormState>();

    setState(() => _isBidSheetOpen = true);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets.copyWith(top: 0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: LotexUiColors.slate950,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(color: Colors.white.withAlpha((0.10 * 255).round())),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LotexI18n.tr(lang, 'placeBid'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  AppInput(
                    label: LotexI18n.tr(lang, 'enterAmount'),
                    controller: bidController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      final raw = v?.trim() ?? '';
                      if (raw.isEmpty) return LotexI18n.tr(lang, 'requiredField');

                      final bid = double.tryParse(raw.replaceAll(',', '.'));
                      if (bid == null) return LotexI18n.tr(lang, 'invalidPrice');
                      if (bid <= auction.currentPrice) {
                        return '${LotexI18n.tr(lang, 'amountMustBeGreaterThan')} ${auction.currentPrice}';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, child) {
                      final state = ref.watch(placeBidControllerProvider);
                      if (state.isLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      return _GradientCta(
                        label: LotexI18n.tr(lang, 'confirmBid'),
                        onTap: () {
                          if (formKey.currentState?.validate() ?? false) {
                            final parsed = double.tryParse(
                              bidController.text.trim().replaceAll(' ', '').replaceAll(',', '.'),
                            );
                            if (parsed == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(LotexI18n.tr(lang, 'invalidPrice'))),
                              );
                              return;
                            }
                            ref
                                .read(placeBidControllerProvider.notifier)
                                .placeBid(auctionId: auction.id, bidAmount: parsed);
                          }
                        },
                      );
                    },
                  ),
                  Consumer(
                    builder: (context, ref, _) {
                      final state = ref.watch(placeBidControllerProvider);
                      if (!state.hasError) return const SizedBox.shrink();
                      final msg = humanError(state.error!);
                      if (msg.trim().isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          msg,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      if (mounted) setState(() => _isBidSheetOpen = false);
      bidController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    final nowUtc = DateTime.now().toUtc();
    final isFinished = nowUtc.isAfter(auction.endDate.toUtc());
    final status = auction.status.trim().toLowerCase();
    final isOwner = user != null && user.uid == auction.sellerId;

    // Show shipping only when the auction has an explicit winner (buyout sets winnerId) and is ended/sold.
    final hasWinner = auction.winnerId?.isNotEmpty ?? false;
    final isWinner = user != null && hasWinner && user.uid == auction.winnerId;
    final needsShipping = isWinner && auction.deliveryInfo == null && (isFinished || status == 'sold');

    // Auto-open shipping once when the user becomes the winner.
    if (needsShipping && !_didAutoOpenShipping) {
      _didAutoOpenShipping = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.push('/shipping/${auction.id}');
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const LotexBackground(),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                title: _StickyHeader(
                  title: auction.title,
                  auctionId: auction.id,
                  onBack: () => Navigator.of(context).maybePop(),
                  onEdit: isOwner ? () => context.push('/auction/edit', extra: auction) : null,
                  onDelete: isOwner ? _confirmDelete : null,
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 960;
                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildGallery()),
                                const SizedBox(width: 24),
                                Expanded(child: _buildDetails(needsShipping: needsShipping)),
                              ],
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildGallery(),
                              const SizedBox(height: 20),
                              _buildDetails(needsShipping: needsShipping),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGallery() {
    final lang = ref.watch(lotexLanguageProvider);
    final imageProvider = _auctionImageProvider();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha((0.10 * 255).round())),
              image: imageProvider != null
                  ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                  : null,
              color: imageProvider == null ? LotexUiColors.slate900 : null,
            ),
            child: Stack(
              children: [
                if (imageProvider == null)
                  const Center(
                    child: Icon(Icons.image_outlined, size: 56, color: LotexUiColors.slate500),
                  ),
                Positioned(
                  left: 16,
                  top: 16,
                  child: _LiveBadge(lang: lang),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(4, (i) {
            final isActive = i == _thumbIndex;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == 3 ? 0 : 10),
                child: InkWell(
                  onTap: () => setState(() => _thumbIndex = i),
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isActive
                              ? LotexUiColors.violet500
                              : Colors.white.withAlpha((0.10 * 255).round()),
                        ),
                        image: imageProvider != null
                            ? DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                                opacity: isActive ? 1.0 : 0.6,
                              )
                            : null,
                        color: imageProvider == null ? LotexUiColors.slate900 : null,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDetails({required bool needsShipping}) {
    final seller = _shortSeller(auction.sellerId);
    final lang = ref.watch(lotexLanguageProvider);
    final user = ref.watch(currentUserProvider);

    final nowUtc = DateTime.now().toUtc();
    final isFinished = nowUtc.isAfter(auction.endDate.toUtc());
    final status = auction.status.trim().toLowerCase();
    final buyout = auction.buyoutPrice;
    final closedStatuses = <String>{
      'sold',
      'ended',
      'closed',
      'shipping_confirmed',
      'shipping',
      'delivered',
      'cancelled',
      'canceled',
      'deleted',
    };
    final isClosed = closedStatuses.contains(status);
    final showBuyout = buyout != null &&
        buyout > 0 &&
        !isFinished &&
        !needsShipping &&
        !isClosed &&
        (user == null || user.uid != auction.sellerId);

    final canMessageSeller =
      auction.sellerId.isNotEmpty && (user == null || user.uid != auction.sellerId);

    final winnerId = (auction.winnerId ?? '').trim();
    final canMessageBuyer = user != null &&
      user.uid == auction.sellerId &&
      winnerId.isNotEmpty &&
      winnerId != user.uid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Badge(
              label: LotexI18n.tr(lang, 'digitalArt'),
              background: LotexUiColors.violet500.withAlpha((0.20 * 255).round()),
              border: LotexUiColors.violet500.withAlpha((0.20 * 255).round()),
              textColor: LotexUiColors.violet400,
            ),
            const SizedBox(width: 8),
            _Badge(
              label: '#${auction.id.substring(0, auction.id.length >= 4 ? 4 : auction.id.length)}',
              background: Colors.white.withAlpha((0.05 * 255).round()),
              border: Colors.white.withAlpha((0.10 * 255).round()),
              textColor: LotexUiColors.slate400,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          auction.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: auction.sellerId.isEmpty ? null : () => context.push('/user/${auction.sellerId}'),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: auction.sellerId.isEmpty
                        ? null
                        : FirebaseFirestore.instance
                            .collection('public_profiles')
                            .doc(auction.sellerId)
                            .snapshots(),
                    builder: (context, snap) {
                      final data = snap.data?.data();
                      final displayName = (data?['displayName'] as String?)?.trim();
                      final name = (displayName != null && displayName.isNotEmpty)
                          ? displayName
                          : seller;

                      final photoURL = ((data?['photoURL'] as String?)?.trim().isNotEmpty ?? false)
                          ? (data?['photoURL'] as String).trim()
                          : (((data?['photoUrl'] as String?)?.trim().isNotEmpty ?? false)
                              ? (data?['photoUrl'] as String).trim()
                              : null);

                      return Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [LotexUiColors.neonPink, LotexUiColors.neonOrange],
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                color: LotexUiColors.slate800,
                                alignment: Alignment.center,
                                child: (photoURL != null && photoURL.isNotEmpty)
                                    ? Image.network(
                                        photoURL,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.person,
                                          size: 18,
                                          color: LotexUiColors.slate400,
                                        ),
                                      )
                                    : const Icon(Icons.person, size: 18, color: LotexUiColors.slate400),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LotexI18n.tr(lang, 'createdBy'),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: LotexUiColors.slate400),
                              ),
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _BidCard(
          currentPriceText: _priceFormat.format(auction.currentPrice),
          endsInWidget: AuctionTimer(
            endTime: auction.endDate,
            builder: (context, timeLeft) {
              final h = timeLeft.inHours;
              final m = timeLeft.inMinutes.remainder(60);
              final s = timeLeft.inSeconds.remainder(60);
              final hs = LotexI18n.tr(lang, 'hoursShort');
              final ms = LotexI18n.tr(lang, 'minutesShort');
              final ss = LotexI18n.tr(lang, 'secondsShort');
              final text = '$h$hs $m$ms $s$ss';
              return Text(
                text,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              );
            },
          ),
          onPlaceBid: _showBidSheet,
          buyoutLabel: showBuyout ? '${LotexI18n.tr(lang, 'buyoutAction')} • ${_priceFormat.format(buyout)}' : null,
          onBuyout: showBuyout ? _confirmBuyout : null,
          lang: lang,
        ),
        if (canMessageSeller) ...[
          const SizedBox(height: 12),
          _SecondaryCta(
            label: LotexI18n.tr(lang, 'messageSeller'),
            onTap: _openChatWithSeller,
          ),
        ],
        if (canMessageBuyer) ...[
          const SizedBox(height: 12),
          _SecondaryCta(
            label: 'Написати покупцю',
            onTap: () => _openChatWithBuyer(winnerId),
          ),
        ],
        const SizedBox(height: 18),
        Text(
          LotexI18n.tr(lang, 'bidHistory'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('auctions')
              .doc(auction.id)
              .collection('bids')
              .orderBy('timestamp', descending: true)
              .limit(20)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
                return Text(
                  LotexI18n.tr(lang, 'errorWithDetails').replaceFirst('{details}', humanError(snapshot.error ?? Exception('Unknown error'))),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: LotexUiColors.slate400),
                );
            }

            final docs = snapshot.data?.docs ?? const [];
            if (docs.isEmpty) {
              return Text(
                LotexI18n.tr(lang, 'noBidsYet'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: LotexUiColors.slate400),
              );
            }

            return Column(
              children: List.generate(docs.length, (i) {
                final data = docs[i].data();
                final userName = (data['userName'] as String?)?.trim();
                final userId = (data['userId'] as String?) ?? '';
                final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
                final ts = data['timestamp'];
                final createdAt = ts is Timestamp ? ts.toDate() : null;

                final title = (userName != null && userName.isNotEmpty) ? userName : _shortSeller(userId);

                return Padding(
                  padding: EdgeInsets.only(bottom: i == docs.length - 1 ? 0 : 8),
                  child: _HistoryRow(
                    address: title,
                    timeAgo: _timeAgoText(lang, createdAt),
                    amountText: _priceFormat.format(amount),
                  ),
                );
              }),
            );
          },
        ),
        const SizedBox(height: 18),
        Text(
          LotexI18n.tr(lang, 'description'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          auction.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: LotexUiColors.slate400,
                height: 1.4,
              ),
        ),
      ],
    );
  }
}

class _StickyHeader extends ConsumerWidget {
  final String title;
  final String auctionId;
  final VoidCallback onBack;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _StickyHeader({
    required this.title,
    required this.auctionId,
    required this.onBack,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoritesProvider.select((s) => s.contains(auctionId)));
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: LotexUiColors.slate950.withAlpha((0.80 * 255).round()),
            border: Border(
              bottom: BorderSide(color: Colors.white.withAlpha((0.10 * 255).round())),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, color: LotexUiColors.slate400),
                  ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, color: LotexUiColors.slate400),
                  ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined, color: LotexUiColors.slate400),
                ),
                IconButton(
                  onPressed: () => ref.read(favoritesProvider.notifier).toggle(auctionId),
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? LotexUiColors.neonOrange : LotexUiColors.slate400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final LotexLanguage lang;

  const _LiveBadge({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha((0.60 * 255).round()),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withAlpha((0.10 * 255).round())),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: LotexUiColors.neonGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            LotexI18n.tr(lang, 'liveAuction'),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color background;
  final Color border;
  final Color textColor;

  const _Badge({
    required this.label,
    required this.background,
    required this.border,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _BidCard extends StatelessWidget {
  final String currentPriceText;
  final Widget endsInWidget;
  final VoidCallback onPlaceBid;
  final String? buyoutLabel;
  final VoidCallback? onBuyout;
  final LotexLanguage lang;

  const _BidCard({
    required this.currentPriceText,
    required this.endsInWidget,
    required this.onPlaceBid,
    this.buyoutLabel,
    this.onBuyout,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.05 * 255).round()),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha((0.10 * 255).round())),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LotexI18n.tr(lang, 'currentBid'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: LotexUiColors.slate400),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentPriceText,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    LotexI18n.tr(lang, 'auctionEndsIn'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: LotexUiColors.slate400),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule, size: 18, color: LotexUiColors.violet400),
                      const SizedBox(width: 8),
                      endsInWidget,
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _GradientCta(
                  label: LotexI18n.tr(lang, 'placeBid'),
                  onTap: onPlaceBid,
                ),
              ),
              if (buyoutLabel != null && onBuyout != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _SecondaryCta(
                    label: buyoutLabel!,
                    onTap: onBuyout!,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user_outlined, size: 14, color: LotexUiColors.slate500),
              const SizedBox(width: 6),
              Text(
                LotexI18n.tr(lang, 'secureTransaction'),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: LotexUiColors.slate500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradientCta extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GradientCta({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LotexUiGradients.primary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: LotexUiShadows.glow,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryCta extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SecondaryCta({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha((0.10 * 255).round()),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAlpha((0.20 * 255).round())),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final String address;
  final String timeAgo;
  final String amountText;

  const _HistoryRow({
    required this.address,
    required this.timeAgo,
    required this.amountText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.03 * 255).round()),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: LotexUiColors.slate800,
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.person_outline, size: 18, color: LotexUiColors.slate400),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeAgo,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: LotexUiColors.slate500),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.trending_up, size: 14, color: LotexUiColors.violet400),
              const SizedBox(width: 6),
              Text(
                amountText,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: LotexUiColors.violet400,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DialogButtonPrimary extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DialogButtonPrimary({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [LotexUiColors.purple600, LotexUiColors.blue600],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

class _DialogButtonSecondary extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DialogButtonSecondary({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha((0.06 * 255).round()),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha((0.10 * 255).round())),
        ),
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}