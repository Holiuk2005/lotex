import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/providers/auth_state_provider.dart';
import 'providers/notifications_providers.dart';
import '../domain/app_notification.dart';

class NotificationsSheet extends ConsumerWidget {
  const NotificationsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final repo = ref.watch(notificationsRepositoryProvider);

    if (user == null) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('Увійдіть, щоб бачити сповіщення.'),
      );
    }

    final notificationsAsync = ref.watch(notificationsStreamProvider);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'Сповіщення',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    await repo.markAllRead(user.uid);
                  },
                  child: const Text(
                    'Позначити все прочитаним',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Flexible(
              child: notificationsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text('Помилка: $e'),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Text('Поки що немає сповіщень.'),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final n = items[i];
                      return _NotificationTile(
                        n: n,
                        onTap: () async {
                          // Optimistic mark as read.
                          if (!n.read) {
                            await repo.markRead(user.uid, n.id, read: true);
                          }

                          if (!context.mounted) return;
                          final auctionId = n.auctionId;
                          if (auctionId == null || auctionId.isEmpty) return;

                          context.push('/auction/$auctionId');
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification n;
  final VoidCallback onTap;

  const _NotificationTile({required this.n, required this.onTap});

  IconData _iconForType() {
    switch (n.type) {
      case 'new_auction':
        return Icons.new_releases_outlined;
      case 'outbid':
        return Icons.trending_down;
      case 'auction_won':
        return Icons.emoji_events_outlined;
      case 'auction_sold':
        return Icons.sell_outlined;
      case 'new_bid':
        return Icons.trending_up;
      default:
        return Icons.notifications_none;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            backgroundColor: isDark
                ? Colors.white.withAlpha((0.06 * 255).round())
                : Colors.black.withAlpha((0.04 * 255).round()),
            child: Icon(_iconForType()),
          ),
          if (!n.read)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        n.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: n.read ? FontWeight.w600 : FontWeight.w800,
        ),
      ),
      subtitle: n.body.isEmpty
          ? null
          : Text(
              n.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
    );
  }
}
