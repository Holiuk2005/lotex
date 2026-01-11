import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../i18n/language_provider.dart';
import '../i18n/lotex_i18n.dart';
import '../theme/lotex_ui_tokens.dart';

class LotexSidebar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const LotexSidebar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  static const double width = 256; // w-64

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(lotexLanguageProvider);
    final isDesktop = MediaQuery.sizeOf(context).width >= 768;
    if (!isDesktop) return const SizedBox.shrink();

    final showLogout = !kIsWeb;

    Widget navItem({
      required int index,
      required IconData icon,
      required String label,
    }) {
      final isActive = currentIndex == index;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onSelect(index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withAlpha((0.10 * 255).round())
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isActive
                    ? [
                        const BoxShadow(
                          color: Color.fromRGBO(168, 85, 247, 0.10),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Keep space reserved so labels/icons never shift.
                  Container(
                    width: 4,
                    height: double.infinity,
                    decoration: isActive
                        ? const BoxDecoration(
                            gradient: LotexUiGradients.sidebarActive,
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(16)),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 24,
                    child: Center(
                      child: Icon(
                        icon,
                        size: 20,
                        color: isActive
                            ? LotexUiColors.violet400
                            : LotexUiColors.slate400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isActive ? Colors.white : LotexUiColors.slate400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: width,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: LotexUiColors.slate950.withAlpha((0.50 * 255).round()),
              border: Border(
                right: BorderSide(
                    color: Colors.white.withAlpha((0.10 * 255).round())),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: LotexUiGradients.primary,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: LotexUiShadows.glow,
                                  ),
                                  child: const Icon(Icons.gavel,
                                      color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ShaderMask(
                                    shaderCallback: (rect) {
                                      return const LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [Colors.white, LotexUiColors.slate400],
                                      ).createShader(rect);
                                    },
                                    child: Text(
                                      LotexI18n.tr(lang, 'appName'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Main nav
                          navItem(
                              index: 0,
                              icon: Icons.home_outlined,
                              label: LotexI18n.tr(lang, 'marketplace')),
                          const SizedBox(height: 8),
                          navItem(
                              index: 1,
                              icon: Icons.favorite_border,
                              label: LotexI18n.tr(lang, 'favorites')),
                          const SizedBox(height: 8),
                          navItem(
                              index: 2,
                              icon: Icons.add,
                              label: LotexI18n.tr(lang, 'sellItem')),
                          const SizedBox(height: 8),
                          navItem(
                              index: 3,
                              icon: Icons.chat_bubble_outline,
                              label: LotexI18n.tr(lang, 'messages')),
                          const SizedBox(height: 8),
                          navItem(
                              index: 4,
                              icon: Icons.person_outline,
                              label: LotexI18n.tr(lang, 'profile')),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Balance card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white
                                      .withAlpha((0.10 * 255).round())),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [LotexUiColors.slate900, LotexUiColors.slate800],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Builder(
                                  builder: (context) {
                                    final user = FirebaseAuth.instance.currentUser;
                                    final createdAt = user?.metadata.creationTime;
                                    final daysOnPlatform = createdAt == null
                                        ? 0
                                        : DateTime.now().difference(createdAt).inDays;

                                    final useMonth = daysOnPlatform >= 30;
                                    final periodDays = useMonth ? 30 : 7;
                                    final titleKey = useMonth ? 'bidOfMonth' : 'bidOfWeek';
                                    final periodKey = useMonth ? 'thisMonth' : 'thisWeek';
                                    final uid = user?.uid;

                                    final stream = uid == null
                                        ? const Stream<QuerySnapshot<Map<String, dynamic>>>.empty()
                                        : FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(uid)
                                            .collection('bids')
                                            .snapshots();

                                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                      stream: stream,
                                      builder: (context, snapshot) {
                                        final since = DateTime.now().subtract(Duration(days: periodDays));

                                        double? best;
                                        final docs = snapshot.data?.docs ?? const [];
                                        for (final d in docs) {
                                          final data = d.data();
                                          final ts = data['timestamp'];
                                          final time = ts is Timestamp ? ts.toDate() : null;
                                          if (time == null || time.isBefore(since)) continue;

                                          final amount = (data['amount'] as num?)?.toDouble();
                                          if (amount == null) continue;
                                          if (best == null || amount > best) best = amount;
                                        }

                                        final valueText = best == null
                                            ? '—'
                                            : LotexI18n.formatCurrency(best, lang);

                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              LotexI18n.tr(lang, titleKey),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: LotexUiColors.slate400,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              valueText,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
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
                                                Expanded(
                                                  child: Text(
                                                    LotexI18n.tr(lang, periodKey),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: LotexUiColors.neonGreen,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.only(top: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                    color: Colors.white
                                        .withAlpha((0.10 * 255).round())),
                              ),
                            ),
                            child: Column(
                              children: [
                                _bottomAction(
                                  icon: Icons.settings,
                                  label: LotexI18n.tr(lang, 'settings'),
                                  onTap: () => context.go('/profile/settings'),
                                ),
                                if (showLogout)
                                  _bottomAction(
                                    icon: Icons.logout,
                                    label: LotexI18n.tr(lang, 'logout'),
                                    onTap: () => context.go('/login'),
                                  ),
                              ],
                            ),
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
    );
  }

  Widget _bottomAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Center(
                  child: Icon(icon, size: 16, color: LotexUiColors.slate500),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: LotexUiColors.slate500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
