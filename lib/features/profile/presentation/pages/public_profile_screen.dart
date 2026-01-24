import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lotex/features/auction/presentation/utils/buyout_flow.dart';

import 'package:lotex/core/i18n/language_provider.dart';
import 'package:lotex/core/i18n/lotex_i18n.dart';
import 'package:lotex/core/theme/lotex_ui_tokens.dart';
import 'package:lotex/core/utils/human_error.dart';
import 'package:lotex/core/widgets/lotex_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lotex/core/widgets/lotex_background.dart';
import 'package:lotex/features/auction/domain/entities/auction_entity.dart';
import 'package:lotex/features/auction/presentation/widgets/lotex_auction_grid_v2.dart';

class PublicProfileScreen extends ConsumerWidget {
  final String uid;

  const PublicProfileScreen({super.key, required this.uid});

  String _short(String id) {
    if (id.isEmpty) return '—';
    final head = id.length >= 6 ? id.substring(0, 6) : id;
    return '$head…';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(lotexLanguageProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: LotexAppBar(
        showBack: true,
        showDefaultActions: false,
        showDesktopSearch: false,
        titleText: LotexI18n.tr(lang, 'profile'),
      ),
      body: Stack(
        children: [
          const LotexBackground(),
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('public_profiles').doc(uid).snapshots(),
            builder: (context, userSnap) {
              final data = userSnap.data?.data();

              final displayName = (data?['displayName'] as String?)?.trim();
              final name = (displayName != null && displayName.isNotEmpty)
                  ? displayName
                  : _short(uid);

              final photoURL = ((data?['photoURL'] as String?)?.trim().isNotEmpty ?? false)
                  ? (data?['photoURL'] as String).trim()
                  : (((data?['photoUrl'] as String?)?.trim().isNotEmpty ?? false)
                      ? (data?['photoUrl'] as String).trim()
                      : null);

              final width = MediaQuery.sizeOf(context).width;
              final pad = EdgeInsets.all(width >= 768 ? 32 : 16);

              return Padding(
                padding: pad,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _Avatar(photoURL: photoURL, fallback: name),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _short(uid),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: LotexUiColors.slate400),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          LotexI18n.tr(lang, 'myLots'),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('auctions')
                                .where('sellerId', isEqualTo: uid)
                                .snapshots(),
                            builder: (context, snap) {
                              if (snap.hasError) {
                                return Center(
                                  child: Text(
                                    LotexI18n.tr(lang, 'errorWithDetails').replaceFirst(
                                      '{details}',
                                      humanError(snap.error ?? Exception('Unknown error')),
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: LotexUiColors.slate400),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }
                              if (!snap.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(color: LotexUiColors.violet500),
                                );
                              }

                              final docs = snap.data!.docs.toList(growable: false);
                              docs.sort((a, b) {
                                DateTime at = DateTime.fromMillisecondsSinceEpoch(0);
                                DateTime bt = DateTime.fromMillisecondsSinceEpoch(0);
                                final aRaw = a.data()['createdAt'];
                                final bRaw = b.data()['createdAt'];
                                if (aRaw is Timestamp) at = aRaw.toDate();
                                if (bRaw is Timestamp) bt = bRaw.toDate();
                                return bt.compareTo(at);
                              });

                              final items = docs.map(AuctionEntity.fromDocument).toList(growable: false);
                              if (items.isEmpty) {
                                return Center(
                                  child: Text(
                                    LotexI18n.tr(lang, 'noAuctionsFound'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: LotexUiColors.slate400),
                                  ),
                                );
                              }

                              return LotexAuctionGridV2(
                                items: items,
                                onSelect: (a) => context.push('/auction', extra: a),
                                onBuyout: (a) => runBuyoutFlow(context: context, ref: ref, auction: a),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? photoURL;
  final String fallback;

  const _Avatar({required this.photoURL, required this.fallback});

  @override
  Widget build(BuildContext context) {
    final url = photoURL;
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [LotexUiColors.neonPink, LotexUiColors.neonOrange],
        ),
      ),
      padding: const EdgeInsets.all(1),
          child: ClipOval(
        child: Container(
          color: LotexUiColors.slate800,
          child: (url != null && url.isNotEmpty)
              ? CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (c, u) => Shimmer.fromColors(
                    baseColor: LotexUiColors.slate800,
                    highlightColor: Colors.black12,
                    child: Container(color: LotexUiColors.slate800),
                  ),
                  errorWidget: (c, u, e) => _Fallback(fallback: fallback),
                )
              : _Fallback(fallback: fallback),
        ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  final String fallback;
  const _Fallback({required this.fallback});

  @override
  Widget build(BuildContext context) {
    final initial = fallback.trim().isNotEmpty ? fallback.trim()[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
      ),
    );
  }
}
