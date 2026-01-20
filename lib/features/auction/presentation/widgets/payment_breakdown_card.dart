import 'package:flutter/material.dart';

import 'package:lotex/core/utils/price_calculator.dart';
import 'package:lotex/core/i18n/lotex_i18n.dart';
import 'package:lotex/core/utils/currency.dart';

class PaymentBreakdownCard extends StatelessWidget {
  final PriceBreakdown breakdown;
  final String currency;

  const PaymentBreakdownCard({
    super.key,
    required this.breakdown,
    this.currency = LotexCurrency.uah,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode == 'uk'
        ? LotexLanguage.uk
        : LotexLanguage.en;
    final localeName = lang == LotexLanguage.uk ? 'uk_UA' : 'en_US';

    final surface = isDark
        ? Colors.white.withAlpha((0.05 * 255).round())
        : Theme.of(context).colorScheme.surface;
    final border = isDark
        ? Colors.white.withAlpha((0.10 * 255).round())
        : Colors.black.withAlpha((0.06 * 255).round());

    final money = LotexCurrency.formatter(
      localeName: localeName,
      code: currency,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          _Row(
            label: LotexI18n.tr(lang, 'paymentLotPrice'),
            valueText: money.format(breakdown.subtotal),
          ),
          const SizedBox(height: 10),
          _Row(
            label: LotexI18n.tr(lang, 'delivery'),
            valueText: money.format(breakdown.shipping),
          ),
          const SizedBox(height: 10),
          _Row(
            labelWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LotexI18n.tr(lang, 'serviceFee2'),
                  style: TextStyle(
                    color: Colors.white.withAlpha((0.62 * 255).round()),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Tooltip(
                  message: LotexI18n.tr(lang, 'buyerProtectionFee'),
                  child: Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.white.withAlpha((0.55 * 255).round()),
                  ),
                ),
              ],
            ),
            valueText: money.format(breakdown.serviceFee),
            valueStyle: TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.white.withAlpha((0.72 * 255).round()),
            ),
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.white.withAlpha((0.10 * 255).round())),
          const SizedBox(height: 14),
          _Row(
            label: LotexI18n.tr(lang, 'paymentToPay'),
            valueText: money.format(breakdown.total),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            valueStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String? label;
  final Widget? labelWidget;
  final String valueText;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const _Row({
    this.label,
    this.labelWidget,
    required this.valueText,
    this.labelStyle,
    this.valueStyle,
  }) : assert(label != null || labelWidget != null);

  @override
  Widget build(BuildContext context) {
    final defaultLabel = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white.withAlpha((0.78 * 255).round()),
          fontWeight: FontWeight.w700,
        );
    final defaultValue = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        );

    return Row(
      children: [
        Expanded(
          child: labelWidget ?? Text(label!, style: labelStyle ?? defaultLabel),
        ),
        Text(
          valueText,
          style: valueStyle ?? defaultValue,
        ),
      ],
    );
  }
}
