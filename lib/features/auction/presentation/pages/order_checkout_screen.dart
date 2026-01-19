import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:lotex/core/theme/lotex_ui_tokens.dart';
import 'package:lotex/core/widgets/lotex_app_bar.dart';
import 'package:lotex/core/widgets/lotex_background.dart';
import 'package:lotex/features/auction/presentation/widgets/branch_picker_sheet.dart';
import 'package:lotex/features/auction/presentation/widgets/city_search_sheet.dart';
import 'package:lotex/services/logistics_service.dart';

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

  final _uah = NumberFormat.currency(
    locale: 'uk_UA',
    symbol: '₴',
    decimalDigits: 0,
  );

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

  double get _total => widget.itemPrice + _shippingCost;

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
        const SnackBar(content: Text('Спочатку оберіть місто.')),
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
        const SnackBar(content: Text('Оберіть місто отримувача.')),
      );
      return;
    }

    final senderCity = await _ensureSenderCity();
    if (senderCity == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не вдалося визначити місто відправника (Київ).')),
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
      SnackBar(content: Text('Вартість доставки оновлено: ${_uah.format(cost)}')),
    );
  }

  Future<void> _buyAndGenerateTtn() async {
    if (_isSubmitting) return;

    final receiverCity = _receiverCity;
    final receiverBranch = _receiverBranch;

    if (receiverCity == null || receiverBranch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Оберіть місто та відділення.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final senderCity = await _ensureSenderCity();
      if (senderCity == null) {
        throw Exception('Sender city (Kyiv) not resolved');
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
      await orderRef.set(<String, dynamic>{
        'id': orderRef.id,
        'userId': uid,
        'itemPrice': widget.itemPrice,
        'shippingCost': _shippingCost,
        'total': _total,
        'senderCityName': senderCity.name,
        'senderCityRef': senderCity.ref,
        'receiverCityName': receiverCity.name,
        'receiverCityRef': receiverCity.ref,
        'receiverBranchName': receiverBranch.description,
        'receiverBranchRef': receiverBranch.ref,
        'senderRef': senderRef,
        'receiverRef': receiverRef,
        'ttn': ttn,
        'status': 'created',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('TTN: $ttn (збережено в orders)')),
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

    final surface = isDark
        ? Colors.white.withAlpha((0.05 * 255).round())
        : Theme.of(context).colorScheme.surface;
    final border = isDark
        ? Colors.white.withAlpha((0.10 * 255).round())
        : Colors.black.withAlpha((0.06 * 255).round());

    return Scaffold(
      appBar: const LotexAppBar(titleText: 'Оформлення замовлення'),
      body: Stack(
        children: [
          const LotexBackground(),
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
            children: [
              Text(
                'Delivery Details',
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
                      decoration: _inputDecoration('City', icon: Icons.location_city).copyWith(
                        hintText: 'Оберіть місто',
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _branchController,
                      readOnly: true,
                      onTap: _pickReceiverBranch,
                      decoration: _inputDecoration('Branch', icon: Icons.store_mall_directory_outlined).copyWith(
                        hintText: _receiverCity == null ? 'Спочатку оберіть місто' : 'Оберіть відділення',
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
                        label: const Text(
                          'Calculate Delivery',
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
                'Payment Breakdown',
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
                    _BreakdownRow(
                      label: 'Item Price',
                      valueText: _uah.format(widget.itemPrice),
                    ),
                    const SizedBox(height: 10),
                    _BreakdownRow(
                      label: 'Delivery Cost',
                      valueText: _uah.format(_shippingCost),
                      leading: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: LotexUiColors.neonOrange.withAlpha((0.18 * 255).round()),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.local_shipping_outlined,
                          size: 16,
                          color: LotexUiColors.neonOrange,
                        ),
                      ),
                      valueStyle: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: LotexUiColors.neonOrange,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Divider(color: Colors.white.withAlpha((0.10 * 255).round())),
                    const SizedBox(height: 14),
                    _BreakdownRow(
                      label: 'Total Payable',
                      valueText: _uah.format(_total),
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
              ),
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
                  _isSubmitting ? 'Processing…' : 'Buy & Generate TTN',
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

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String valueText;
  final Widget? leading;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const _BreakdownRow({
    required this.label,
    required this.valueText,
    this.leading,
    this.labelStyle,
    this.valueStyle,
  });

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
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Text(
            label,
            style: labelStyle ?? defaultLabel,
          ),
        ),
        Text(
          valueText,
          style: valueStyle ?? defaultValue,
        ),
      ],
    );
  }
}
