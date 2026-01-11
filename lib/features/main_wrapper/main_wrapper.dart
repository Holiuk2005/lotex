import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lotex/core/widgets/lotex_bottom_nav.dart';
import 'package:lotex/core/widgets/lotex_sidebar.dart';
import 'package:lotex/core/theme/lotex_ui_tokens.dart';
import 'package:lotex/features/auction/presentation/providers/create_submit_provider.dart';

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
                goTo(2);
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
