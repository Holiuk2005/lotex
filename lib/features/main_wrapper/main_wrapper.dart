import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lotex/core/widgets/lotex_bottom_nav.dart';
import 'package:lotex/core/widgets/lotex_sidebar.dart';
import 'package:lotex/core/theme/lotex_ui_tokens.dart';
import 'package:lotex/features/auction/presentation/providers/create_submit_provider.dart';
import 'package:lotex/core/i18n/language_provider.dart';
import 'package:lotex/core/i18n/lotex_i18n.dart';

class MainWrapper extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapper({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mq = MediaQuery.of(context);
    final isDesktopWidth = mq.size.width >= 768;
    final isWebMobile = kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    final isDesktop = isDesktopWidth && !isWebMobile;

    void goTo(int index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );

    void showSellOptions(BuildContext context, WidgetRef ref) {
      final lang = ref.watch(lotexLanguageProvider);
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final bg = isDark
              ? LotexUiColors.slate950.withOpacity(0.92)
              : Theme.of(context).colorScheme.surface;
          
          return Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LotexI18n.tr(lang, 'sell'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.gavel_outlined, color: LotexUiColors.violet500, size: 28),
                  title: Text(LotexI18n.tr(lang, 'createAuction')),
                  subtitle: const Text('Виставити товар на аукціон зі ставками'),
                  onTap: () {
                    Navigator.pop(context);
                    goTo(2);
                  },
                ),
                const Divider(height: 1, color: Colors.white10),
                ListTile(
                  leading: const Icon(Icons.storefront_outlined, color: LotexUiColors.blue500, size: 28),
                  title: const Text('Створити товар на Маркетплейсі', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Продати товар за фіксованою ціною'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/marketplace/create');
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      );
    }

    final isCreateBranch = navigationShell.currentIndex == 2;

    Widget sellFab() {
      final submitCallback = ref.watch(createSubmitCallbackProvider);
      const double buttonSize = 72;
      const double overlapFraction = 0.75;
      const double overlap = buttonSize * overlapFraction;
      final double bottomInset = MediaQuery.paddingOf(context).bottom;
      final double bottom = (LotexBottomNav.height + bottomInset) - overlap;

      return Positioned(
        left: 0,
        right: 0,
        bottom: bottom,
        child: Center(
          child: GestureDetector(
            onTap: () {
              if (isCreateBranch && submitCallback != null) {
                submitCallback();
              } else {
                showSellOptions(context, ref);
              }
            },
            child: Material(
              color: Colors.transparent,
              elevation: 12,
              shadowColor:
                  LotexUiColors.violet500.withAlpha((0.45 * 255).round()),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [LotexUiColors.violet600, LotexUiColors.blue600],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withAlpha((0.20 * 255).round()),
                  ),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: isDesktop
          ? Row(
              children: [
                LotexSidebar(
                  currentIndex: navigationShell.currentIndex,
                  onSelect: goTo,
                ),
                Expanded(child: navigationShell),
              ],
            )
          : (isCreateBranch
              // Important: the create screen already owns its bottom action button.
              // If we overlay the global bottom nav + FAB, the user can't see/press
              // "Create lot" and it feels like the plus icon "disappears".
              ? navigationShell
              : Stack(
                  children: [
                    navigationShell,
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: LotexBottomNav(
                        currentIndex: navigationShell.currentIndex,
                        onSelect: goTo,
                      ),
                    ),
                    // Foreground action above ALL screens (except Create branch).
                    sellFab(),
                  ],
                )),
    );
  }
}
