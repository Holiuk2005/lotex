import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:lotex/services/logistics_service.dart';

class ShippingSelector extends StatefulWidget {
  final LogisticsService logistics;
  final String? sellerCityRef;
  final double lotPrice;
  final ValueChanged<City?>? onCitySelected;
  final ValueChanged<Branch?>? onWarehouseSelected;

  const ShippingSelector({
    super.key,
    required this.logistics,
    this.sellerCityRef,
    this.lotPrice = 0,
    this.onCitySelected,
    this.onWarehouseSelected,
  });

  @override
  State<ShippingSelector> createState() => _ShippingSelectorState();
}

class _ShippingSelectorState extends State<ShippingSelector> {
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _warehouseCtrl = TextEditingController();
  List<Branch> _warehouses = [];
  List<City> _cityResults = [];
  bool _loadingWarehouses = false;
  bool _loadingCities = false;
  bool _calculatingPrice = false;
  String? _priceError;
  double? _calculatedPrice;
  DateTime? _estimatedDelivery;
  Timer? _debounce;

  @override
  void dispose() {
    _cityCtrl.dispose();
    _warehouseCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadWarehouses(String city) async {
    setState(() {
      _loadingWarehouses = true;
      _warehouses = [];
      _warehouseCtrl.text = '';
    });
    try {
      final list = await widget.logistics.getWarehouses(city);
      if (!mounted) return;
      setState(() => _warehouses = list);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _warehouses = [];
      });
    } finally {
      if (!mounted) return;
      setState(() => _loadingWarehouses = false);
    }
  }

  Future<void> _searchCitiesDebounced(String pattern) async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final q = pattern.trim();
      if (q.isEmpty) {
        if (!mounted) return;
        setState(() {
          _cityResults = [];
        });
        return;
      }

      setState(() {
        _loadingCities = true;
        _cityResults = [];
      });

      try {
        final res = await widget.logistics.searchCities(q);
        if (!mounted) return;
        setState(() => _cityResults = res);
      } catch (e) {
        if (!mounted) return;
        setState(() => _cityResults = []);
      } finally {
        if (!mounted) return;
        setState(() => _loadingCities = false);
      }
    });
  }

  Future<void> _calculatePriceIfReady() async {
    City? receiver;
    for (final c in _cityResults) {
      if (c.name.toLowerCase() == _cityCtrl.text.toLowerCase()) {
        receiver = c;
        break;
      }
    }
    if (receiver == null && _cityResults.isNotEmpty) receiver = _cityResults.first;
    if (receiver == null || _warehouses.isEmpty || widget.sellerCityRef == null) return;
    final branch = _warehouses.firstWhere((b) => b.description == _warehouseCtrl.text, orElse: () => _warehouses.first);

    setState(() {
      _calculatingPrice = true;
      _priceError = null;
      _calculatedPrice = null;
      _estimatedDelivery = null;
    });

    try {
      final doc = await widget.logistics.getDocumentPrice(
        citySender: widget.sellerCityRef!,
        cityRecipient: receiver.ref,
        weight: 1.0,
        cost: widget.lotPrice,
      );

      double price = 0;
      if (doc['data'] is List && doc['data'].isNotEmpty) {
        final first = doc['data'][0];
        final v = first['Cost'];
        if (v is num) {
          price = v.toDouble();
        } else if (v is String) price = double.tryParse(v.replaceAll(',', '.')) ?? 0;
        // Some NP responses may include delivery date fields; try to parse.
        if (first['DeliveryDate'] is String) {
          try {
            _estimatedDelivery = DateTime.parse(first['DeliveryDate']);
          } catch (_) {
            _estimatedDelivery = null;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _calculatedPrice = price;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _priceError = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() => _calculatingPrice = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // City input with debounced search
        TextFormField(
          controller: _cityCtrl,
          decoration: const InputDecoration(labelText: 'City'),
          onChanged: (v) async {
            await _searchCitiesDebounced(v);
          },
        ),
        if (_loadingCities) const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator()),
        if (!_loadingCities && _cityResults.isNotEmpty)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _cityResults.length,
              itemBuilder: (context, i) {
                final c = _cityResults[i];
                return ListTile(
                  title: Text(c.name),
                  subtitle: Text(c.ref),
                  onTap: () {
                    _cityCtrl.text = c.name;
                    widget.onCitySelected?.call(c);
                    _cityResults.clear();
                    _loadWarehouses(c.ref);
                  },
                );
              },
            ),
          ),
        const SizedBox(height: 12),
        _loadingWarehouses
            ? const Center(child: SizedBox(height: 36, width: 36, child: CircularProgressIndicator()))
            : _warehouses.isEmpty
                ? TextFormField(
                    controller: _warehouseCtrl,
                    decoration: const InputDecoration(labelText: 'Warehouse'),
                    readOnly: true,
                  )
                : DropdownButtonFormField<Branch>(
                    value: _warehouses.firstWhere((b) => b.description == _warehouseCtrl.text, orElse: () => _warehouses.first),
                    items: _warehouses
                        .map((b) => DropdownMenuItem(value: b, child: Text(b.description)))
                        .toList(growable: false),
                    onChanged: (v) {
                      if (v == null) return;
                      _warehouseCtrl.text = v.description;
                      widget.onWarehouseSelected?.call(v);
                      // Calculate price immediately
                      _calculatePriceIfReady();
                    },
                    decoration: const InputDecoration(labelText: 'Warehouse'),
                  ),

        const SizedBox(height: 12),
        if (_calculatingPrice) const Center(child: CircularProgressIndicator()),
        if (_priceError != null) Text('Error: $_priceError', style: const TextStyle(color: Colors.red)),
        if (_calculatedPrice != null)
          Text('Shipping: ${_calculatedPrice?.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
        if (_estimatedDelivery != null)
          Text('Estimated delivery: ${_estimatedDelivery?.toLocal().toIso8601String().split('T').first}'),
      ],
    );
  }
}
