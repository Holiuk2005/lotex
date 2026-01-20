import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lotex/core/i18n/language_provider.dart';
import 'package:lotex/core/i18n/lotex_i18n.dart';
import 'package:lotex/core/theme/lotex_ui_tokens.dart';
import 'package:lotex/core/utils/human_error.dart';
import 'package:lotex/core/widgets/app_button.dart';
import 'package:lotex/core/widgets/lotex_app_bar.dart';
import 'package:lotex/core/widgets/lotex_background.dart';
import 'package:lotex/features/auction/data/repositories/auction_repository.dart';
import 'package:lotex/features/auction/domain/entities/delivery_info.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String auctionId;

  const PaymentScreen({super.key, required this.auctionId});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isSaving = false;
  bool _didInitSelection = false;
  PaymentMethod _selected = PaymentMethod.cardOnline;

  PaymentMethod _parsePaymentMethod(dynamic raw) {
    final name = (raw as String?)?.trim();
    if (name == null || name.isEmpty) return PaymentMethod.cardOnline;

    // Backward compatibility for old values.
    if (name == PaymentMethod.cardTransfer.name) return PaymentMethod.cardOnline;

    return PaymentMethod.values.firstWhere(
      (p) => p.name == name,
      orElse: () => PaymentMethod.cardOnline,
    );
  }

  String _labelFor(LotexLanguage lang, PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cardOnline:
        return LotexI18n.tr(lang, 'paymentCardOnline');
      case PaymentMethod.applePay:
        return LotexI18n.tr(lang, 'paymentApplePay');
      case PaymentMethod.googlePay:
        return LotexI18n.tr(lang, 'paymentGooglePay');
      case PaymentMethod.cashOnDelivery:
        return LotexI18n.tr(lang, 'paymentCashOnDelivery');
      case PaymentMethod.cashPickup:
        return LotexI18n.tr(lang, 'paymentCashPickup');
      case PaymentMethod.cardTransfer:
        // Old value; show as online card.
        return LotexI18n.tr(lang, 'paymentCardOnline');
    }
  }

  IconData _iconFor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cardOnline:
        return Icons.credit_card;
      case PaymentMethod.applePay:
        return Icons.phone_iphone;
      case PaymentMethod.googlePay:
        return Icons.account_balance_wallet;
      case PaymentMethod.cashOnDelivery:
        return Icons.local_shipping_outlined;
      case PaymentMethod.cashPickup:
        return Icons.payments_outlined;
      case PaymentMethod.cardTransfer:
        return Icons.credit_card;
    }
  }

  List<PaymentMethod> _availableMethods({required DeliveryProvider? provider}) {
    if (provider == DeliveryProvider.pickup) {
      return const [PaymentMethod.cashPickup];
    }
    return const [
      PaymentMethod.cardOnline,
      PaymentMethod.applePay,
      PaymentMethod.googlePay,
      PaymentMethod.cashOnDelivery,
    ];
  }

  Future<void> _save(PaymentMethod method) async {
    setState(() => _isSaving = true);
    try {
      await ref.read(auctionRepositoryProvider).setPaymentMethod(widget.auctionId, method);
      if (!mounted) return;
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      final lang = ref.read(lotexLanguageProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LotexI18n.tr(lang, 'errorWithDetails').replaceFirst('{details}', humanError(e)),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(lotexLanguageProvider);

    final auctionStream = FirebaseFirestore.instance.collection('auctions').doc(widget.auctionId).snapshots();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: LotexAppBar(
        showBack: true,
        showDefaultActions: false,
        showDesktopSearch: false,
        titleText: LotexI18n.tr(lang, 'paymentTitle'),
      ),
      body: Stack(
        children: [
          const LotexBackground(),
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: auctionStream,
            builder: (context, snap) {
              final data = snap.data?.data();
              final title = (data?['title'] as String?) ?? '';

              final imageUrl = (data?['imageUrl'] as String?)?.trim();
              final currentPrice = (data?['currentPrice'] as num?)?.toDouble() ?? 0.0;
              final currency = ((data?['currency'] as String?) ?? 'UAH').trim();
              final currentPriceText = LotexI18n.formatCurrency(
                currentPrice,
                lang,
                currency: currency,
              );

              final deliveryInfo = data?['deliveryInfo'];
              final providerRaw = (deliveryInfo is Map) ? deliveryInfo['provider'] : null;
              final provider = DeliveryProvider.values.firstWhere(
                (p) => p.name == (providerRaw as String? ?? ''),
                orElse: () => DeliveryProvider.novaPoshtaBranch,
              );

              final savedMethodRaw = (deliveryInfo is Map) ? deliveryInfo['paymentMethod'] : null;
              final savedMethod = _parsePaymentMethod(savedMethodRaw);

              if (!_didInitSelection && snap.hasData) {
                _didInitSelection = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  setState(() => _selected = savedMethod);
                });
              }

              final available = _availableMethods(provider: provider);
              final canSave = deliveryInfo is Map;

              final left = _Section(
                title: LotexI18n.tr(lang, 'paymentMethodTitle'),
                child: Column(
                  children: available
                      .map(
                        (m) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _PaymentTile(
                            title: _labelFor(lang, m),
                            icon: _iconFor(m),
                            value: m,
                            groupValue: _selected,
                            onChanged: (v) => setState(() => _selected = v),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              );

              final right = _Section(
                title: LotexI18n.tr(lang, 'paymentSummaryTitle'),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withAlpha((0.10 * 255).round())),
                        color: LotexUiColors.slate900,
                        image: (imageUrl != null && imageUrl.isNotEmpty)
                            ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                            : null,
                      ),
                      child: (imageUrl == null || imageUrl.isEmpty)
                          ? const Center(
                              child: Icon(Icons.image_outlined, size: 24, color: LotexUiColors.slate500),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.isNotEmpty ? title : LotexI18n.tr(lang, 'lot'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 10),
                          _SummaryRow(
                            label: LotexI18n.tr(lang, 'paymentLotPrice'),
                            value: currentPriceText,
                          ),
                          const SizedBox(height: 6),
                          _SummaryRow(
                            label: LotexI18n.tr(lang, 'paymentToPay'),
                            value: currentPriceText,
                            bold: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 860;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!canSave)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  LotexI18n.tr(lang, 'paymentNeedShippingFirst'),
                                  style: const TextStyle(color: LotexUiColors.slate400),
                                ),
                              ),
                            if (isWide)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: left),
                                  const SizedBox(width: 16),
                                  Expanded(child: right),
                                ],
                              )
                            else ...[
                              left,
                              const SizedBox(height: 16),
                              right,
                            ],
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: AppButton.primary(
                                label: _isSaving
                                    ? LotexI18n.tr(lang, 'pleaseWait')
                                    : LotexI18n.tr(lang, 'paymentConfirmAction'),
                                onPressed: (!canSave || _isSaving) ? null : () => _save(_selected),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.05 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha((0.10 * 255).round())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final PaymentMethod value;
  final PaymentMethod groupValue;
  final ValueChanged<PaymentMethod> onChanged;

  const _PaymentTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.04 * 255).round()),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? LotexUiColors.violet500.withAlpha((0.55 * 255).round())
                  : Colors.white.withAlpha((0.08 * 255).round()),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: selected ? LotexUiColors.violet400 : LotexUiColors.slate400),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 18,
                height: 18,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 2,
                      color: selected
                          ? LotexUiColors.violet500
                          : Colors.white.withAlpha((0.25 * 255).round()),
                    ),
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: LotexUiColors.violet500,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: bold ? Colors.white : LotexUiColors.slate400,
      fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
    );

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}
