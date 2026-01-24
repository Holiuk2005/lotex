import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:lotex/services/nova_poshta_service.dart';

class ShippingSelector extends StatefulWidget {
  final NovaPoshtaService nova;
  final ValueChanged<String>? onCitySelected;
  final ValueChanged<String>? onWarehouseSelected;

  const ShippingSelector({super.key, required this.nova, this.onCitySelected, this.onWarehouseSelected});

  @override
  State<ShippingSelector> createState() => _ShippingSelectorState();
}

class _ShippingSelectorState extends State<ShippingSelector> {
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _warehouseCtrl = TextEditingController();
  List<String> _warehouses = [];
  bool _loadingWarehouses = false;

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
      final list = await widget.nova.searchWarehouses(city);
      if (!mounted) return;
      setState(() {
        _warehouses = list;
      });
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TypeAheadFormField<String>(
          textFieldConfiguration: TextFieldConfiguration(
            controller: _cityCtrl,
            decoration: const InputDecoration(labelText: 'City'),
          ),
          suggestionsCallback: (pattern) async {
            if (pattern.trim().isEmpty) return <String>[];
            try {
              final res = await widget.nova.searchCities(pattern.trim());
              return res;
            } catch (_) {
              return <String>[];
            }
          },
          itemBuilder: (context, String suggestion) {
            return ListTile(title: Text(suggestion));
          },
          onSuggestionSelected: (String suggestion) {
            _cityCtrl.text = suggestion;
            widget.onCitySelected?.call(suggestion);
            _loadWarehouses(suggestion);
          },
          noItemsFoundBuilder: (context) => const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No cities found'),
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
                : TypeAheadFormField<String>(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _warehouseCtrl,
                      decoration: const InputDecoration(labelText: 'Warehouse'),
                    ),
                    suggestionsCallback: (pattern) async {
                      final q = pattern.trim().toLowerCase();
                      return _warehouses.where((w) => w.toLowerCase().contains(q)).toList(growable: false);
                    },
                    itemBuilder: (context, String suggestion) => ListTile(title: Text(suggestion)),
                    onSuggestionSelected: (s) {
                      _warehouseCtrl.text = s;
                      widget.onWarehouseSelected?.call(s);
                    },
                    noItemsFoundBuilder: (context) => const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('No warehouses found'),
                    ),
                  ),
      ],
    );
  }
}
