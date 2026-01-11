import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../i18n/language_provider.dart';
import '../i18n/lotex_i18n.dart';
import '../theme/lotex_ui_tokens.dart';

class LotexBottomNav extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onSelect;

  static const double height = 96;

  const LotexBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(lotexLanguageProvider);

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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                if (isActive)
                  Positioned(
                    top: -6,
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LotexUiGradients.bottomNavActive,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(139, 92, 246, 0.5),
                            blurRadius: 10,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 24,
                      color: isActive ? Colors.white : LotexUiColors.slate500,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isActive ? Colors.white : LotexUiColors.slate500,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    final bg = LotexUiColors.slate950.withAlpha((0.80 * 255).round());

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            border: Border(
              top: BorderSide(color: Colors.white.withAlpha((0.10 * 255).round())),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              // Slightly taller to avoid RenderFlex overflow on smaller devices/textScale.
              height: height,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final horizontal = constraints.maxWidth <= 320 ? 8.0 : 16.0;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: navItem(index: 0, icon: Icons.home_outlined, label: LotexI18n.tr(lang, 'home')),
                        ),
                        Expanded(
                          child: navItem(index: 1, icon: Icons.favorite_border, label: LotexI18n.tr(lang, 'saved')),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              LotexI18n.tr(lang, 'sell'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: LotexUiColors.slate400,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: navItem(
                            index: 3,
                            icon: Icons.chat_bubble_outline,
                            label: LotexI18n.tr(lang, 'messages'),
                          ),
                        ),
                        Expanded(
                          child: navItem(index: 4, icon: Icons.person_outline, label: LotexI18n.tr(lang, 'profile')),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
