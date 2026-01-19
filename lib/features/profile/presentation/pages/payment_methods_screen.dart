import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lotex/core/i18n/language_provider.dart';
import 'package:lotex/core/i18n/lotex_i18n.dart';
import 'package:lotex/core/theme/lotex_ui_tokens.dart';
import 'package:lotex/core/utils/human_error.dart';
import 'package:lotex/core/widgets/app_button.dart';
import 'package:lotex/core/widgets/lotex_app_bar.dart';
import 'package:lotex/core/widgets/lotex_background.dart';
import 'package:lotex/features/profile/presentation/providers/payment_methods_providers.dart';

class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref, {
    required String paymentMethodId,
  }) async {
    final lang = ref.read(lotexLanguageProvider);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(LotexI18n.tr(lang, 'delete')),
        content: Text(LotexI18n.tr(lang, 'paymentMethodDeleteConfirm')),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(LotexI18n.tr(lang, 'cancel'))),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(LotexI18n.tr(lang, 'delete'))),
        ],
      ),
    );

    if (ok != true) return;
    await ref.read(paymentMethodsControllerProvider.notifier).remove(paymentMethodId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(lotexLanguageProvider);

    ref.listen(paymentMethodsControllerProvider, (prev, next) {
      next.whenOrNull(
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                LotexI18n.tr(lang, 'errorWithDetails').replaceFirst('{details}', humanError(e)),
              ),
            ),
          );
        },
      );
    });

    final methods = ref.watch(myPaymentMethodsProvider);
    final actionState = ref.watch(paymentMethodsControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: LotexAppBar(
        showBack: true,
        showDefaultActions: false,
        showDesktopSearch: false,
        titleText: LotexI18n.tr(lang, 'paymentMethods'),
      ),
      body: Stack(
        children: [
          const LotexBackground(),
          methods.when(
            loading: () => const Center(
              child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  LotexI18n.tr(lang, 'errorWithDetails').replaceFirst('{details}', humanError(e)),
                  style: const TextStyle(color: LotexUiColors.slate400, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            data: (items) {
              return RefreshIndicator(
                onRefresh: () => ref.read(paymentMethodsControllerProvider.notifier).refresh(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _Section(
                      title: LotexI18n.tr(lang, 'paymentMethods'),
                      child: items.isEmpty
                          ? Text(
                              LotexI18n.tr(lang, 'paymentMethodsEmpty'),
                              style: const TextStyle(color: LotexUiColors.slate400, fontWeight: FontWeight.w600),
                            )
                          : Column(
                              children: items
                                  .map(
                                    (m) => Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: _MethodTile(
                                        title: _humanTitle(lang, m.brand, m.last4),
                                        subtitle: _subtitle(lang, m.expMonth, m.expYear, isDefault: m.isDefault, wallet: m.wallet),
                                        isDefault: m.isDefault,
                                        onSetDefault: m.isDefault
                                            ? null
                                            : () => ref.read(paymentMethodsControllerProvider.notifier).setDefault(m.id),
                                        onDelete: () => _confirmDelete(context, ref, paymentMethodId: m.id),
                                      ),
                                    ),
                                  )
                                  .toList(growable: false),
                            ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton.primary(
                        label: actionState.isLoading
                            ? LotexI18n.tr(lang, 'pleaseWait')
                            : LotexI18n.tr(lang, 'paymentMethodAddCard'),
                        onPressed: actionState.isLoading
                            ? null
                            : () => ref.read(paymentMethodsControllerProvider.notifier).addCardWithPaymentSheet(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      LotexI18n.tr(lang, 'paymentMethodStripeNote'),
                      style: const TextStyle(color: LotexUiColors.slate500, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

String _humanTitle(LotexLanguage lang, String brand, String last4) {
  final b = brand.trim().isEmpty ? LotexI18n.tr(lang, 'unknown') : brand;
  final tail = last4.trim().isEmpty ? '' : ' • •••• $last4';
  return '$b$tail';
}

String _subtitle(LotexLanguage lang, int expMonth, int expYear, {required bool isDefault, String? wallet}) {
  final mm = expMonth.toString().padLeft(2, '0');
  final yy = (expYear % 100).toString().padLeft(2, '0');
  final exp = '$mm/$yy';
  final parts = <String>[
    '${LotexI18n.tr(lang, 'expiryDate')}: $exp',
  ];
  if (wallet != null && wallet.trim().isNotEmpty) {
    parts.add(wallet.trim());
  }
  if (isDefault) {
    parts.add(LotexI18n.tr(lang, 'paymentMethodDefault'));
  }
  return parts.join(' • ');
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
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDefault;
  final VoidCallback? onSetDefault;
  final VoidCallback onDelete;

  const _MethodTile({
    required this.title,
    required this.subtitle,
    required this.isDefault,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.04 * 255).round()),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDefault
              ? LotexUiColors.violet500.withAlpha((0.55 * 255).round())
              : Colors.white.withAlpha((0.08 * 255).round()),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: LotexUiColors.slate900,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAlpha((0.10 * 255).round())),
            ),
            child: Icon(
              Icons.credit_card,
              color: isDefault ? LotexUiColors.violet400 : LotexUiColors.slate400,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: LotexUiColors.slate400, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz, color: LotexUiColors.slate400),
            color: LotexUiColors.slate950,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'default',
                enabled: onSetDefault != null,
                child: const Text('Default', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ],
            onSelected: (v) {
              if (v == 'default' && onSetDefault != null) onSetDefault!();
              if (v == 'delete') onDelete();
            },
          ),
        ],
      ),
    );
  }
}
