import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notifications_sheet.dart';
import 'providers/notifications_providers.dart';

class NotificationsBellButton extends ConsumerWidget {
  const NotificationsBellButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final unreadAsync = ref.watch(unreadNotificationsCountProvider);
    final unread = unreadAsync.valueOrNull ?? 0;

    Future<void> openSheet() async {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          final bg = isDark
              ? Colors.black.withAlpha((0.65 * 255).round())
              : Colors.black.withAlpha((0.35 * 255).round());
          return Container(
            decoration: BoxDecoration(color: bg),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 520,
                  maxHeight: MediaQuery.sizeOf(context).height * 0.70,
                ),
                child: Material(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  clipBehavior: Clip.antiAlias,
                  child: const NotificationsSheet(),
                ),
              ),
            ),
          );
        },
      );
    }

    return IconButton(
      onPressed: openSheet,
      tooltip: 'Сповіщення',
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.notifications_none,
            color: isDark
                ? const Color(0xFF94A3B8) // slate400
                : Theme.of(context).colorScheme.onSurface,
          ),
          if (unread > 0)
            Positioned(
              top: -2,
              right: -2,
              child: _Badge(
                count: unread,
                isDark: isDark,
              ),
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  final bool isDark;

  const _Badge({required this.count, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final text = count > 9 ? '9+' : '$count';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark
              ? const Color(0xFF020617) // slate950-ish
              : Theme.of(context).colorScheme.surface,
          width: 2,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}
