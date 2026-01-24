import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lotex/core/theme/lotex_ui_tokens.dart';
import 'package:lotex/features/auction/domain/entities/delivery_info.dart';

class ShippingProviderSelector extends StatelessWidget {
  final DeliveryProvider selected;
  final ValueChanged<DeliveryProvider> onSelected;
  final List<DeliveryProvider> providers;

  const ShippingProviderSelector({
    super.key,
    required this.selected,
    required this.onSelected,
    this.providers = const [
      DeliveryProvider.novaPoshta,
      DeliveryProvider.ukrPoshta,
      DeliveryProvider.meestExpress,
    ],
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? Colors.white.withAlpha((0.06 * 255).round()) : Colors.white;
    final border = isDark ? Colors.white.withAlpha((0.12 * 255).round()) : Colors.black.withAlpha((0.08 * 255).round());
    final textColor = isDark ? LotexUiColors.darkTitle : LotexUiColors.lightTitle;
    final subtitleColor = isDark ? LotexUiColors.darkMuted : LotexUiColors.lightMuted;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.18 * 255).round()),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Оберіть перевізника',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              itemCount: providers.length,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final provider = providers[index];
                final isSelected = provider == selected;

                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onSelected(provider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? LotexUiColors.violet500.withAlpha((0.55 * 255).round())
                            : border,
                        width: isSelected ? 1.4 : 1,
                      ),
                      boxShadow: isSelected ? LotexUiShadows.glow : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withAlpha((0.08 * 255).round())
                                : Colors.black.withAlpha((0.04 * 255).round()),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SvgPicture.asset(
                            provider.assetPath,
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider.displayName(
                                  localeCode: Localizations.localeOf(context).languageCode,
                                ),
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: textColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isSelected ? 'Обрано' : 'Натисніть для вибору',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: subtitleColor,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isSelected ? Icons.check_circle : Icons.radio_button_off,
                          color: isSelected ? LotexUiColors.violet500 : subtitleColor,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
