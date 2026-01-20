import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:lotex/core/theme/lotex_ui_tokens.dart';
import 'package:lotex/core/widgets/lotex_app_bar.dart';
import 'package:lotex/core/widgets/lotex_background.dart';
import 'package:lotex/features/auction/presentation/widgets/branch_picker_sheet.dart';
import 'package:lotex/features/auction/presentation/widgets/city_search_sheet.dart';
import 'package:lotex/features/auction/presentation/widgets/payment_breakdown_card.dart';
import 'package:lotex/core/utils/price_calculator.dart';
import 'package:lotex/features/orders/domain/order_entity.dart';
import 'package:lotex/services/logistics_service.dart';
import 'package:lotex/core/i18n/lotex_i18n.dart';

class OrderCheckoutScreen extends StatefulWidget {
  final double itemPrice;
  final double shippingCost;

  const OrderCheckoutScreen({
    super.key,
    required this.itemPrice,
    this.shippingCost = 0,
  });

  @override
  State<OrderCheckoutScreen> createState() => _OrderCheckoutScreenState();
}

class _OrderCheckoutScreenState extends State<OrderCheckoutScreen> {
  late final TextEditingController _cityController;
  late final TextEditingController _branchController;

  late double _shippingCost;
  bool _isSubmitting = false;

  final _logistics = LogisticsService();

  City? _senderCity;
  City? _receiverCity;
  Branch? _receiverBranch;

  LotexLanguage _langOf(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'uk'
        ? LotexLanguage.uk
        : LotexLanguage.en;
  }

  String _localeNameOf(BuildContext context) {
    return _langOf(context) == LotexLanguage.uk ? 'uk_UA' : 'en_US';
  }

  String _tr(BuildContext context, String key) {
    return LotexI18n.tr(_langOf(context), key);
  }

  NumberFormat _uah(BuildContext context, {int decimalDigits = 0}) {
    return NumberFormat.currency(
      locale: _localeNameOf(context),
      symbol: '₴',
      decimalDigits: decimalDigits,
    );
  }

  PriceBreakdown get _breakdown =>
      PriceCalculator.calculateBreakdown(widget.itemPrice, _shippingCost);

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController();
    _branchController = TextEditingController();
    _shippingCost = widget.shippingCost;
  }

  @override
  void dispose() {
    _cityController.dispose();
    _branchController.dispose();
    super.dispose();
  }


  Future<City?> _ensureSenderCity() async {
    if (_senderCity != null) return _senderCity;
    final cities = await _logistics.searchCity('Київ');
    if (cities.isEmpty) return null;
    _senderCity = cities.first;
    return _senderCity;
  }

  Future<void> _pickReceiverCity() async {
    final picked = await showModalBottomSheet<City>(
      context: context,
      isScrollControlled: true,
      builder: (context) => CitySearch(logistics: _logistics),
    );

    if (picked == null || !mounted) return;
    setState(() {
      _receiverCity = picked;
      _receiverBranch = null;
      _cityController.text = picked.name;
      _branchController.text = '';
    });
  }

  Future<void> _pickReceiverBranch() async {
    final city = _receiverCity;
    if (city == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_tr(context, 'checkoutPickCityFirst'))),
      );
      return;
    }

    final picked = await showModalBottomSheet<Branch>(
      context: context,
      isScrollControlled: true,
      builder: (context) => BranchPickerSheet(
        logistics: _logistics,
        cityRef: city.ref,
      ),
    );

    if (picked == null || !mounted) return;
    setState(() {
      _receiverBranch = picked;
      _branchController.text = picked.description;
    });
  }

  Future<void> _calculateDelivery() async {
    final receiverCity = _receiverCity;
    if (receiverCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_tr(context, 'checkoutPickReceiverCity'))),
      );
      return;
    }

    final senderCity = await _ensureSenderCity();
    if (senderCity == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_tr(context, 'checkoutSenderCityFailed'))),
      );
      return;
    }

    const weight = 1.0;

    final cost = await _logistics.calculateShippingCost(
      citySender: senderCity.ref,
      cityReceiver: receiverCity.ref,
      weight: weight,
      cost: widget.itemPrice,
    );

    if (!mounted) return;
    setState(() {
      _shippingCost = cost;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _tr(context, 'checkoutShippingUpdated')
              .replaceAll('{price}', _uah(context).format(cost)),
        ),
      ),
    );
  }

  Future<void> _buyAndGenerateTtn() async {
    if (_isSubmitting) return;

    final lang = _langOf(context);
    String tr(String key) => LotexI18n.tr(lang, key);

    final receiverCity = _receiverCity;
    final receiverBranch = _receiverBranch;

    if (receiverCity == null || receiverBranch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('checkoutPickCityAndBranch'))),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final senderCity = await _ensureSenderCity();
      if (senderCity == null) {
        throw Exception(tr('checkoutSenderCityFailed'));
      }

      // For now we store refs we have (City + Warehouse Ref).
      // Full InternetDocument/save requires more fields.
      final senderRef = senderCity.ref;
      final receiverRef = receiverBranch.ref;

      final ttn = await _logistics.createTTN(
        senderRef: senderRef,
        receiverRef: receiverRef,
      );

      final uid = FirebaseAuth.instance.currentUser?.uid;
      final orderRef = FirebaseFirestore.instance.collection('orders').doc();

      final order = OrderEntity(
        id: orderRef.id,
        userId: uid,
        breakdown: _breakdown,
        senderCityName: senderCity.name,
        senderCityRef: senderCity.ref,
        receiverCityName: receiverCity.name,
        receiverCityRef: receiverCity.ref,
        receiverBranchName: receiverBranch.description,
        receiverBranchRef: receiverBranch.ref,
        senderRef: senderRef,
        receiverRef: receiverRef,
        ttn: ttn,
      );

      await orderRef.set(order.toDocument());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr('checkoutTtnSaved').replaceAll('{ttn}', ttn),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.white.withAlpha((0.10 * 255).round())
        : Colors.black.withAlpha((0.08 * 255).round());

    return InputDecoration(
      labelText: label,
      prefixIcon: icon == null
          ? null
          : Icon(icon, size: 18, color: LotexUiColors.slate400),
      filled: true,
      fillColor: isDark
          ? Colors.white.withAlpha((0.05 * 255).round())
          : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: LotexUiColors.violet500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = _langOf(context);

    final surface = isDark
        ? Colors.white.withAlpha((0.05 * 255).round())
        : Theme.of(context).colorScheme.surface;
    final border = isDark
        ? Colors.white.withAlpha((0.10 * 255).round())
        : Colors.black.withAlpha((0.06 * 255).round());

    return Scaffold(
      appBar: LotexAppBar(titleText: LotexI18n.tr(lang, 'checkoutTitle')),
      body: Stack(
        children: [
          const LotexBackground(),
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
            children: [
              Text(
                LotexI18n.tr(lang, 'shippingTitle'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: border),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _cityController,
                      readOnly: true,
                      onTap: _pickReceiverCity,
                      decoration: _inputDecoration(
                        LotexI18n.tr(lang, 'shippingCityLabel'),
                        icon: Icons.location_city,
                      ).copyWith(
                        hintText: LotexI18n.tr(lang, 'shippingCityHint'),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _branchController,
                      readOnly: true,
                      onTap: _pickReceiverBranch,
                      decoration: _inputDecoration(
                        LotexI18n.tr(lang, 'checkoutBranchLabel'),
                        icon: Icons.store_mall_directory_outlined,
                      ).copyWith(
                        hintText: _receiverCity == null
                            ? LotexI18n.tr(lang, 'checkoutPickCityFirst')
                            : LotexI18n.tr(lang, 'checkoutPickBranch'),
                      ),
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: _calculateDelivery,
                        icon: const Icon(Icons.local_shipping_outlined, size: 18),
                        label: Text(
                          LotexI18n.tr(lang, 'checkoutCalculateDelivery'),
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withAlpha((0.16 * 255).round()),
                          ),
                          backgroundColor: Colors.white.withAlpha((0.06 * 255).round()),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                LotexI18n.tr(lang, 'paymentSummaryTitle'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 10),
              PaymentBreakdownCard(breakdown: _breakdown),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: SizedBox(
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LotexUiGradients.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: LotexUiColors.violet500.withAlpha((0.22 * 255).round()),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: TextButton(
                onPressed: _isSubmitting ? null : _buyAndGenerateTtn,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _isSubmitting
                      ? LotexI18n.tr(lang, 'pleaseWait')
                      : LotexI18n.tr(lang, 'checkoutBuyGenerateTtn'),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
