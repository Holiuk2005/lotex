import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lotex/core/constants/shipping_logos.dart';

import 'package:lotex/core/i18n/language_provider.dart';
import 'package:lotex/core/i18n/lotex_i18n.dart';
import 'package:lotex/core/theme/lotex_ui_tokens.dart';
import 'package:lotex/core/widgets/app_button.dart';
import 'package:lotex/core/widgets/app_input.dart';
import 'package:lotex/core/widgets/lotex_app_bar.dart';
import 'package:lotex/core/widgets/lotex_background.dart';
import 'package:lotex/core/utils/human_error.dart';
import 'package:lotex/features/auction/data/repositories/auction_repository.dart';
import 'package:lotex/features/auction/domain/entities/delivery_info.dart';
import 'package:lotex/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:lotex/features/chat/presentation/pages/chat_conversation_screen.dart';
import 'package:lotex/features/chat/presentation/providers/chat_providers.dart';

class ShippingScreen extends ConsumerStatefulWidget {
  final String auctionId;

  const ShippingScreen({super.key, required this.auctionId});

  @override
  ConsumerState<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends ConsumerState<ShippingScreen> {
  final _formKey = GlobalKey<FormState>();

  DeliveryProvider _selectedProvider = DeliveryProvider.novaPoshta;

  final _cityController = TextEditingController();
  final _departmentController = TextEditingController();
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isSubmitting = false;

  bool _isCourier() => _selectedProvider == DeliveryProvider.novaPoshtaCourier;

  bool _isLocker() => _selectedProvider == DeliveryProvider.novaPoshtaLocker;

  bool _isPickup() => _selectedProvider == DeliveryProvider.pickup;

  String _providerLabel(LotexLanguage lang, DeliveryProvider p) {
    final locale = lang == LotexLanguage.en ? 'en' : 'uk';
    if (p == DeliveryProvider.pickup) {
      return lang == LotexLanguage.en
          ? 'Pickup (meet seller)'
          : 'Самовивіз (зустріч з продавцем)';
    }
    return p.displayName(localeCode: locale);
  }

  String? _providerLogoAsset(DeliveryProvider p) {
    final fromMap = shippingLogos[p.name];
    final asset = (fromMap ?? p.iconPath).trim();
    return asset.isEmpty ? null : asset;
  }

  Widget _providerLeadingIcon(DeliveryProvider p) {
    final asset = _providerLogoAsset(p);
    if (asset == null) {
      return const Icon(Icons.handshake_outlined, size: 18, color: LotexUiColors.slate400);
    }

    if (asset.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        asset,
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => const SizedBox(
          width: 22,
          height: 22,
          child: Center(
            child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ),
      );
    }

    return Image.asset(
      asset,
      width: 22,
      height: 22,
      fit: BoxFit.contain,
    );
  }

  Future<void> _openChatWithSeller({required String sellerId, required String title}) async {
    final authUser = ref.read(authStateChangesProvider).maybeWhen(data: (u) => u, orElse: () => null);
    if (authUser == null) {
      if (!mounted) return;
      context.push('/login');
      return;
    }

    final buyerId = authUser.uid;
    final repo = ref.read(chatRepositoryProvider);

    try {
      final dialogId = await repo.ensureAuctionDialog(
        auctionId: widget.auctionId,
        buyerId: buyerId,
        sellerId: sellerId,
        title: title,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatConversationScreen(dialogId: dialogId, role: 'buyer', title: title),
        ),
      );
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
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final paymentMethod = _isPickup() ? PaymentMethod.cashPickup : PaymentMethod.cashOnDelivery;

    final info = DeliveryInfo(
      provider: _selectedProvider,
      paymentMethod: paymentMethod,
      city: _cityController.text.trim(),
      departmentNumber: (_isCourier() || _isPickup()) ? '' : _departmentController.text.trim(),
      fullAddress: _isCourier() ? _addressController.text.trim() : '',
      recipientName: _nameController.text.trim(),
      recipientPhone: _phoneController.text.trim(),
    );

    setState(() => _isSubmitting = true);
    try {
      await ref.read(auctionRepositoryProvider).confirmShipping(widget.auctionId, info);
      if (!mounted) return;

      final ok = await context.push<bool>('/payment/${widget.auctionId}');
      if (!mounted) return;
      if (ok == true) {
        final lang = ref.read(lotexLanguageProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LotexI18n.tr(lang, 'shippingSaved'))),
        );
        context.pop();
      }
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
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    _departmentController.dispose();
    _addressController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
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
        titleText: LotexI18n.tr(lang, 'shippingTitle'),
      ),
      body: Stack(
        children: [
          const LotexBackground(),
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: auctionStream,
            builder: (context, snap) {
              final auction = snap.data?.data();
              final sellerId = (auction?['sellerId'] as String?) ?? '';
              final title = (auction?['title'] as String?) ?? (lang == LotexLanguage.en ? 'Auction' : 'Лот');

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Section(
                            title: LotexI18n.tr(lang, 'shippingStep1'),
                            child: ShippingMethodSelector(
                              providers: const [
                                DeliveryProvider.novaPoshta,
                                DeliveryProvider.ukrPoshta,
                                DeliveryProvider.meestExpress,
                                DeliveryProvider.pickup,
                              ],
                              selected: _selectedProvider,
                              onChanged: (v) {
                                setState(() {
                                  _selectedProvider = v;
                                  _departmentController.clear();
                                  _addressController.clear();
                                });
                              },
                              labelBuilder: (p) => _providerLabel(lang, p),
                              iconBuilder: (p) => _providerLeadingIcon(p),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _Section(
                            title: LotexI18n.tr(lang, 'shippingStep2'),
                            child: Column(
                              children: [
                                AppInput(
                                  label: LotexI18n.tr(lang, 'shippingCityLabel'),
                                  controller: _cityController,
                                  hint: LotexI18n.tr(lang, 'shippingCityHint'),
                                  validator: (v) => (v == null || v.trim().isEmpty)
                                      ? LotexI18n.tr(lang, 'requiredField')
                                      : null,
                                ),
                                const SizedBox(height: 12),
                                if (_isPickup())
                                  const SizedBox.shrink()
                                else if (_isCourier())
                                  AppInput(
                                    label: LotexI18n.tr(lang, 'shippingAddressLabel'),
                                    controller: _addressController,
                                    hint: LotexI18n.tr(lang, 'shippingAddressHint'),
                                    validator: (v) => (v == null || v.trim().isEmpty)
                                        ? LotexI18n.tr(lang, 'requiredField')
                                        : null,
                                  )
                                else
                                  AppInput(
                                    label: _isLocker()
                                        ? LotexI18n.tr(lang, 'shippingLockerLabel')
                                        : LotexI18n.tr(lang, 'shippingDepartmentLabel'),
                                    controller: _departmentController,
                                    hint: _isLocker()
                                        ? LotexI18n.tr(lang, 'shippingLockerHint')
                                        : LotexI18n.tr(lang, 'shippingDepartmentHint'),
                                    keyboardType: TextInputType.number,
                                    validator: (v) => (v == null || v.trim().isEmpty)
                                        ? LotexI18n.tr(lang, 'requiredField')
                                        : null,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _Section(
                            title: LotexI18n.tr(lang, 'shippingStep3'),
                            child: Column(
                              children: [
                                AppInput(
                                  label: LotexI18n.tr(lang, 'shippingNameLabel'),
                                  controller: _nameController,
                                  hint: LotexI18n.tr(lang, 'shippingNameHint'),
                                  validator: (v) => (v == null || v.trim().isEmpty)
                                      ? LotexI18n.tr(lang, 'requiredField')
                                      : null,
                                ),
                                const SizedBox(height: 12),
                                AppInput(
                                  label: LotexI18n.tr(lang, 'shippingPhoneLabel'),
                                  controller: _phoneController,
                                  hint: LotexI18n.tr(lang, 'shippingPhoneHint'),
                                  keyboardType: TextInputType.phone,
                                  validator: (v) => (v == null || v.trim().isEmpty)
                                      ? LotexI18n.tr(lang, 'requiredField')
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (sellerId.isNotEmpty)
                            SizedBox(
                              width: double.infinity,
                              child: AppButton.secondary(
                                label: (lang == LotexLanguage.en) ? 'Message seller' : 'Написати продавцю',
                                onPressed: _isSubmitting
                                    ? null
                                    : () => _openChatWithSeller(sellerId: sellerId, title: title),
                              ),
                            ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: AppButton.primary(
                              label: _isSubmitting
                                  ? LotexI18n.tr(lang, 'pleaseWait')
                                  : LotexI18n.tr(lang, 'confirmShipping'),
                              onPressed: _isSubmitting ? null : _submit,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
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

class ShippingMethodSelector extends StatelessWidget {
  final List<DeliveryProvider> providers;
  final DeliveryProvider selected;
  final ValueChanged<DeliveryProvider> onChanged;
  final String Function(DeliveryProvider) labelBuilder;
  final Widget Function(DeliveryProvider) iconBuilder;

  const ShippingMethodSelector({
    super.key,
    required this.providers,
    required this.selected,
    required this.onChanged,
    required this.labelBuilder,
    required this.iconBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? Colors.white.withAlpha((0.06 * 255).round()) : Colors.white;
    final border = isDark ? Colors.white.withAlpha((0.12 * 255).round()) : Colors.black.withAlpha((0.08 * 255).round());
    final textColor = isDark ? LotexUiColors.darkTitle : LotexUiColors.lightTitle;
    final mutedColor = isDark ? LotexUiColors.darkMuted : LotexUiColors.lightMuted;

    return Column(
      children: providers
          .map(
            (p) {
              final isSelected = p == selected;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => onChanged(p),
                  borderRadius: BorderRadius.circular(18),
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
                          child: Center(child: iconBuilder(p)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                labelBuilder(p),
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: textColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isSelected ? 'Обрано' : 'Натисніть для вибору',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: mutedColor,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isSelected ? Icons.check_circle : Icons.radio_button_off,
                          color: isSelected ? LotexUiColors.violet500 : mutedColor,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
          .toList(growable: false),
    );
  }
}

class _RadioTile<T> extends StatelessWidget {
  final String title;
  final Widget? leading;
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;

  const _RadioTile({
    required this.title,
    this.leading,
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              if (leading != null) ...[
                SizedBox(width: 22, height: 22, child: Center(child: leading)),
                const SizedBox(width: 10),
              ],
              SizedBox(
                width: 20,
                height: 20,
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
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: LotexUiColors.violet500,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
