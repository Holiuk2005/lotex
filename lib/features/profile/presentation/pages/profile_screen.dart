import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lotex/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:lotex/core/widgets/lotex_app_bar.dart';
import 'package:lotex/core/widgets/lotex_background.dart';
import 'package:lotex/core/theme/lotex_ui_tokens.dart';
import 'package:lotex/features/auth/domain/entities/user_entity.dart';
import 'package:lotex/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:lotex/core/i18n/language_provider.dart';
import 'package:lotex/core/i18n/lotex_i18n.dart';
import 'package:lotex/core/utils/human_error.dart';
import 'package:lotex/features/auction/domain/entities/auction_entity.dart';
import 'package:lotex/features/auction/presentation/providers/auction_list_provider.dart';
import 'package:lotex/features/auction/presentation/widgets/lotex_auction_card_v2.dart';
import 'package:lotex/features/auction/presentation/utils/buyout_flow.dart';
import 'package:lotex/features/favorites/presentation/providers/favorites_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _tabIndex = 0;

  Future<void> _showLogoutDialog(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Вихід'),
        content: const Text('Ви дійсно бажаєте вийти з акаунту?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Скасувати',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Вийти', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await ref.read(authControllerProvider.notifier).signOut();
      // Тут не потрібно context.go('/login'), бо StreamBuilder сам оновить UI на _GuestView
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);
    final lang = ref.watch(lotexLanguageProvider);

    return Scaffold(
      appBar: LotexAppBar(
        titleText: LotexI18n.tr(lang, 'profile'),
        showDefaultActions: false,
        showDesktopSearch: false,
      ),
      body: Stack(
        children: [
          const LotexBackground(),
          authState.when(
            data: (user) {
              if (user == null) {
                return const _GuestView();
              }
              return _UserView(
                user: user,
                tabIndex: _tabIndex,
                onTabChanged: (index) => setState(() => _tabIndex = index),
                onLogoutTap: () {
                  _showLogoutDialog(context);
                },
                lang: lang,
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: LotexUiColors.violet500),
            ),
            error: (err, stack) => Center(child: Text('Помилка: ${humanError(err)}')),
          ),
        ],
      ),
    );
  }
}

// --- ВИГЛЯД ДЛЯ АВТОРИЗОВАНОГО КОРИСТУВАЧА ---
class _UserView extends ConsumerWidget {
  final UserEntity user;
  final int tabIndex;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onLogoutTap;
  final LotexLanguage lang;

  const _UserView({
    required this.user,
    required this.tabIndex,
    required this.onTabChanged,
    required this.onLogoutTap,
    required this.lang,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = user.uid;
    final isMobileWeb = kIsWeb && MediaQuery.sizeOf(context).width < 768;
    return SingleChildScrollView(
      child: Column(
        children: [
          _HeaderBanner(user: user, lang: lang),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _GlassButton(
                        icon: Icons.settings_outlined,
                        label: LotexI18n.tr(lang, 'settings'),
                        onTap: () {
                          context.go('/profile/settings');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GradientButton(
                        icon: Icons.edit_outlined,
                        label: LotexI18n.tr(lang, 'editProfile'),
                        onTap: () async {
                          final updated = await Navigator.push<bool?>(
                            context,
                            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                          );
                          if (updated == true && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(LotexI18n.tr(lang, 'profileUpdated'))),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                if (isMobileWeb) ...[
                  const SizedBox(height: 12),
                  _LogoutButton(onTap: onLogoutTap, lang: lang),
                ],
                const SizedBox(height: 20),
                _StatsGrid(lang: lang),
                const SizedBox(height: 16),
                _Tabs(
                  index: tabIndex,
                  onChanged: onTabChanged,
                  lang: lang,
                ),
                const SizedBox(height: 16),
                _TabContent(
                  tabIndex: tabIndex,
                  userId: uid,
                  lang: lang,
                ),
                const SizedBox(height: 16),
                if (!isMobileWeb) _LogoutButton(onTap: onLogoutTap, lang: lang),
                const SizedBox(height: 24),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabContent extends ConsumerWidget {
  final int tabIndex;
  final String userId;
  final LotexLanguage lang;

  const _TabContent({
    required this.tabIndex,
    required this.userId,
    required this.lang,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (tabIndex) {
      case 0:
        return _CollectedTab(userId: userId, lang: lang);
      case 1:
        return _CreatedTab(userId: userId, lang: lang);
      case 2:
        return _ActivityTab(userId: userId, lang: lang);
      case 3:
        return _FavoritedTab(lang: lang);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _CreatedTab extends StatelessWidget {
  final String userId;
  final LotexLanguage lang;
  const _CreatedTab({required this.userId, required this.lang});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).brightness == Brightness.dark ? LotexUiColors.darkMuted : LotexUiColors.lightMuted;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('auctions')
          .where('sellerId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            LotexI18n.tr(lang, 'errorWithDetails')
                .replaceFirst('{details}', humanError(snapshot.error ?? Exception('Unknown error'))),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: LotexUiColors.slate400),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: LotexUiColors.violet500));
        }

        final sorted = snapshot.data!.docs.toList(growable: false);
        sorted.sort((a, b) {
          DateTime at = DateTime.fromMillisecondsSinceEpoch(0);
          DateTime bt = DateTime.fromMillisecondsSinceEpoch(0);

          final aRaw = a.data()['createdAt'];
          final bRaw = b.data()['createdAt'];
          if (aRaw is Timestamp) at = aRaw.toDate();
          if (bRaw is Timestamp) bt = bRaw.toDate();
          return bt.compareTo(at);
        });

        final docs = sorted.take(50).toList(growable: false);
        if (docs.isEmpty) {
          return Text(
            LotexI18n.tr(lang, 'noAuctionsFound'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: LotexUiColors.slate400),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final auction = AuctionEntity.fromDocument(docs[index]);
            return Material(
              color: Colors.white.withAlpha((0.05 * 255).round()),
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${auction.currentPrice.toStringAsFixed(0)} ${LotexI18n.tr(lang, 'currency')}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted),
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
    );
  }
}

class _ActivityTab extends StatelessWidget {
  final String userId;
  final LotexLanguage lang;
  const _ActivityTab({required this.userId, required this.lang});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).brightness == Brightness.dark ? LotexUiColors.darkMuted : LotexUiColors.lightMuted;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('bids')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            LotexI18n.tr(lang, 'errorWithDetails')
                .replaceFirst('{details}', humanError(snapshot.error ?? Exception('Unknown error'))),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: LotexUiColors.slate400),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: LotexUiColors.violet500));
        }

        final sorted = snapshot.data!.docs.toList(growable: false);
        sorted.sort((a, b) {
          DateTime at = DateTime.fromMillisecondsSinceEpoch(0);
          DateTime bt = DateTime.fromMillisecondsSinceEpoch(0);

          final aRaw = a.data()['timestamp'];
          final bRaw = b.data()['timestamp'];
          if (aRaw is Timestamp) at = aRaw.toDate();
          if (bRaw is Timestamp) bt = bRaw.toDate();
          return bt.compareTo(at);
        });

        final docs = sorted.take(50).toList(growable: false);
        if (docs.isEmpty) {
          return Text(
            LotexI18n.tr(lang, 'noBidsYet'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: LotexUiColors.slate400),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
            final ts = data['timestamp'];
            final time = ts is Timestamp ? ts.toDate() : null;
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.05 * 255).round()),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha((0.10 * 255).round())),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: LotexUiColors.violet500.withAlpha((0.15 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.history_rounded, color: LotexUiColors.violet600),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${amount.toStringAsFixed(0)} ${LotexI18n.tr(lang, 'currency')}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          time != null ? time.toString() : '—',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CollectedTab extends ConsumerWidget {
  final String userId;
  final LotexLanguage lang;
  const _CollectedTab({required this.userId, required this.lang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('auctions')
          .where('winnerId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            LotexI18n.tr(lang, 'errorWithDetails')
                .replaceFirst('{details}', humanError(snapshot.error ?? Exception('Unknown error'))),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: LotexUiColors.slate400),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: LotexUiColors.violet500));
        }

        final sorted = snapshot.data!.docs.toList(growable: false);
        sorted.sort((a, b) {
          DateTime at = DateTime.fromMillisecondsSinceEpoch(0);
          DateTime bt = DateTime.fromMillisecondsSinceEpoch(0);

          final aRaw = a.data()['createdAt'];
          final bRaw = b.data()['createdAt'];
          if (aRaw is Timestamp) at = aRaw.toDate();
          if (bRaw is Timestamp) bt = bRaw.toDate();
          return bt.compareTo(at);
        });

        final docs = sorted.take(50).toList(growable: false);
        if (docs.isEmpty) {
          return Text(
            LotexI18n.tr(lang, 'noAuctionsFound'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: LotexUiColors.slate400),
          );
        }

        final isWide = MediaQuery.sizeOf(context).width >= 768;

        if (!isWide) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 24),
            itemBuilder: (context, i) {
              final a = AuctionEntity.fromDocument(docs[i]);
              return LotexAuctionCardV2(
                auction: a,
                onTap: () => context.push('/auction', extra: a),
                onBuyout: () => runBuyoutFlow(context: context, ref: ref, auction: a),
              );
            },
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio: 0.58,
          ),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final a = AuctionEntity.fromDocument(docs[i]);
            return LotexAuctionCardV2(
              auction: a,
              onTap: () => context.push('/auction', extra: a),
              onBuyout: () => runBuyoutFlow(context: context, ref: ref, auction: a),
            );
          },
        );
      },
    );
  }
}

class _FavoritedTab extends ConsumerWidget {
  final LotexLanguage lang;
  const _FavoritedTab({required this.lang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoritesProvider);
    final auctionsAsync = ref.watch(auctionListProvider);

    return auctionsAsync.when(
      data: (auctions) {
        final items = auctions.where((a) => favoriteIds.contains(a.id)).toList(growable: false);
        if (items.isEmpty) {
          return Text(
            LotexI18n.tr(lang, 'favoritesEmpty'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: LotexUiColors.slate400),
          );
        }

        final isWide = MediaQuery.sizeOf(context).width >= 768;

        if (!isWide) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 24),
            itemBuilder: (context, i) {
              final a = items[i];
              return LotexAuctionCardV2(
                auction: a,
                onTap: () => context.push('/auction', extra: a),
                onBuyout: () => runBuyoutFlow(context: context, ref: ref, auction: a),
              );
            },
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio: 0.58,
          ),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final a = items[i];
            return LotexAuctionCardV2(
              auction: a,
              onTap: () => context.push('/auction', extra: a),
              onBuyout: () => runBuyoutFlow(context: context, ref: ref, auction: a),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: LotexUiColors.violet500)),
      error: (e, st) => Text(
        LotexI18n.tr(lang, 'errorWithDetails').replaceFirst('{details}', humanError(e)),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: LotexUiColors.slate400),
      ),
    );
  }
}

String _handleFromEmail(String email) {
  final parts = email.split('@');
  if (parts.isEmpty) return 'user';
  final handle = parts.first.trim();
  return handle.isEmpty ? 'user' : handle;
}

class _HeaderBanner extends StatelessWidget {
  final UserEntity user;
  final LotexLanguage lang;
  const _HeaderBanner({required this.user, required this.lang});

  @override
  Widget build(BuildContext context) {
    final displayName = (user.displayName?.trim().isNotEmpty ?? false) ? user.displayName!.trim() : 'Користувач Lotex';
    final handle = _handleFromEmail(user.email);

    return SizedBox(
      height: 264,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 192,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  LotexUiColors.violet900,
                  LotexUiColors.blue900,
                ],
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    LotexUiColors.slate950.withAlpha((0.95 * 255).round()),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _ProfileAvatar(user: user),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@$handle • ${LotexI18n.tr(lang, 'joined')} —',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: LotexUiColors.slate400,
                              ),
                        ),
                      ],
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

class _ProfileAvatar extends StatelessWidget {
  final UserEntity user;
  const _ProfileAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final photoUrl = user.photoURL;
    return Container(
      width: 128,
      height: 128,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: LotexUiColors.slate900,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LotexUiColors.slate950, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.35 * 255).round()),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: photoUrl != null && photoUrl.isNotEmpty
            ? Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: LotexUiColors.slate800,
                    alignment: Alignment.center,
                    child: Text(
                      user.email.isNotEmpty ? user.email[0].toUpperCase() : 'U',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                    ),
                  );
                },
              )
            : Container(
                color: LotexUiColors.slate800,
                alignment: Alignment.center,
                child: Text(
                  user.email.isNotEmpty ? user.email[0].toUpperCase() : 'U',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                ),
              ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GlassButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha((0.10 * 255).round()),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha((0.10 * 255).round())),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GradientButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LotexUiGradients.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: LotexUiShadows.glow,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
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

class _StatsGrid extends StatelessWidget {
  final LotexLanguage lang;
  const _StatsGrid({required this.lang});

  @override
  Widget build(BuildContext context) {
    final stats = [
      (LotexI18n.tr(lang, 'totalVolume'), '—'),
      (LotexI18n.tr(lang, 'itemsCollected'), '—'),
      (LotexI18n.tr(lang, 'highestBid'), '—'),
      (LotexI18n.tr(lang, 'auctionsWon'), '—'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final crossAxisCount = maxWidth >= 720 ? 4 : 2;

        // Grid tiles have a fixed height derived from `childAspectRatio`.
        // On some widths this can become too short and causes a small bottom overflow.
        // Give tiles a bit more height on narrow/smaller layouts.
        final bool isNarrow = maxWidth < 420;
        final childAspectRatio = crossAxisCount == 2
            ? (isNarrow ? 1.55 : 1.85)
            : 2.15;

        final tilePadding = EdgeInsets.all(isNarrow ? 12 : 14);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final (label, value) = stats[index];
            return Container(
              padding: tilePadding,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.05 * 255).round()),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withAlpha((0.10 * 255).round())),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: LotexUiColors.slate400,
                        ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _Tabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final LotexLanguage lang;

  const _Tabs({required this.index, required this.onChanged, required this.lang});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      LotexI18n.tr(lang, 'profileCollected'),
      LotexI18n.tr(lang, 'profileCreated'),
      LotexI18n.tr(lang, 'profileActivity'),
      LotexI18n.tr(lang, 'profileFavorited'),
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withAlpha((0.10 * 255).round())),
        ),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = i == index;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(i),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12, top: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tabs[i],
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: isActive ? Colors.white : LotexUiColors.slate500,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 2,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isActive ? LotexUiColors.violet500 : Colors.transparent,
                        boxShadow: isActive ? LotexUiShadows.glow : const [],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  final LotexLanguage lang;
  const _LogoutButton({required this.onTap, required this.lang});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha((0.06 * 255).round()),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAlpha((0.10 * 255).round())),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, size: 18, color: LotexUiColors.darkTitle),
            const SizedBox(width: 10),
            Text(
              LotexI18n.tr(lang, 'logout'),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: LotexUiColors.darkTitle,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- ВИГЛЯД ДЛЯ ГОСТЯ ---
class _GuestView extends StatelessWidget {
  const _GuestView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.06 * 255).round()),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withAlpha((0.10 * 255).round())),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 56,
                color: LotexUiColors.violet400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Ласкаво просимо!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Увійдіть або зареєструйтесь, щоб купувати та продавати лоти.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: LotexUiColors.slate400,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            _GradientButton(
              icon: Icons.login,
              label: 'УВІЙТИ',
              onTap: () => context.go('/login'),
            ),
            const SizedBox(height: 12),
            _GlassButton(
              icon: Icons.person_add_alt_1,
              label: 'ЗАРЕЄСТРУВАТИСЯ',
              onTap: () => context.go('/register'),
            ),
          ],
        ),
      ),
    );
  }
}
