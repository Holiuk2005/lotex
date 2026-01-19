import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/lotex_ui_tokens.dart';
import 'theme_toggle.dart';
import '../../features/notifications/presentation/notifications_bell_button.dart';

class LotexAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showDesktopSearch;
  final PreferredSizeWidget? bottom;
  final bool showBack;
  final VoidCallback? onBackPressed;
  final String? titleText;
  final List<Widget> extraActions;
  final bool showDefaultActions;
  final bool showThemeToggle;

  const LotexAppBar({
    super.key,
    this.showDesktopSearch = true,
    this.bottom,
    this.showBack = false,
    this.onBackPressed,
    this.titleText,
    this.extraActions = const [],
    this.showDefaultActions = true,
    this.showThemeToggle = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(64 + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? LotexUiColors.violet500 : Theme.of(context).colorScheme.primary;
    final muted = isDark ? LotexUiColors.slate400 : LotexUiColors.lightMuted;
    final width = MediaQuery.sizeOf(context).width;
    // Keep in sync with desktop shell/sidebar breakpoint.
    final isWide = width >= 768;
    final isDesktop = width >= 900;

    final bg = isDark
      ? LotexUiColors.slate950.withAlpha((0.80 * 255).round())
      : Theme.of(context).colorScheme.surface.withAlpha((0.90 * 255).round());
    final border = isDark ? Colors.white.withAlpha((0.05 * 255).round()) : Theme.of(context).dividerColor;

    final canPop = Navigator.of(context).canPop();
    final shouldShowBack = showBack || canPop;

    return AppBar(
      toolbarHeight: 64,
      elevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: shouldShowBack,
      leading: shouldShowBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.of(context).maybePop(),
              tooltip: 'Назад',
            )
          : null,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              border: Border(bottom: BorderSide(color: border)),
            ),
          ),
        ),
      ),
      bottom: bottom,
      titleSpacing: 16,
      title: titleText != null
          ? Text(
              titleText!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
              ),
            )
          : Row(
              children: [
                if (!isWide)
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => GoRouter.of(context).go('/home'),
                    child: Row(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            gradient: LotexUiGradients.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: LotexUiShadows.glow,
                          ),
                          child: const Icon(
                            Icons.gavel,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Lotex',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isDesktop && showDesktopSearch) ...[
                  if (!isWide) const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        onChanged: (_) {},
                        decoration: InputDecoration(
                          hintText: 'Пошук лотів…',
                          prefixIcon: Icon(Icons.search, color: muted),
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withAlpha((0.05 * 255).round())
                              : LotexUiColors.lightBackground,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.white.withAlpha((0.10 * 255).round())
                                  : Theme.of(context).dividerColor.withAlpha((0.7 * 255).round()),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide(color: primary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
      actions: [
        ...extraActions,
        if (showDefaultActions) ...[
          const NotificationsBellButton(),
          if (isDesktop)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: isDark ? LotexUiGradients.primary : null,
                  color: isDark ? null : primary,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: isDark ? LotexUiShadows.glow : null,
                ),
                child: TextButton(
                  onPressed: () => GoRouter.of(context).go('/create'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  ),
                  child: const Text('Створити лот', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          if (showThemeToggle) const ThemeToggle(),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => GoRouter.of(context).go('/profile'),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              margin: const EdgeInsets.only(right: 12, left: 6),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withAlpha((0.05 * 255).round()) : LotexUiColors.lightBackground,
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? Colors.white.withAlpha((0.10 * 255).round()) : Theme.of(context).dividerColor),
              ),
              child: Icon(Icons.person, size: 18, color: muted),
            ),
          ),
        ],
      ],
    );
  }
}
