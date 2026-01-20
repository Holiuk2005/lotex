import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lotex/core/i18n/category_i18n.dart';
import 'package:lotex/core/i18n/lotex_i18n.dart';
import 'package:lotex/features/home/models/filter_state.dart';
import 'package:lotex/services/category_seed_service.dart';

class FilterBottomSheet extends StatefulWidget {
  final FilterState initial;
  final List<CategoryModel> categories;

  const FilterBottomSheet({
    super.key,
    required this.initial,
    required this.categories,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late FilterState _state;

  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;
  Timer? _priceDebounce;

  static const double _minPrice = 0;
  static const double _maxPrice = 100000;

  @override
  void initState() {
    super.initState();
    _state = widget.initial;
    _minPriceController = TextEditingController(
      text: _state.priceRange.start.round().toString(),
    );
    _maxPriceController = TextEditingController(
      text: _state.priceRange.end.round().toString(),
    );
  }

  @override
  void dispose() {
    _priceDebounce?.cancel();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _setPriceRange(RangeValues values, {bool syncText = true}) {
    var start = values.start;
    var end = values.end;

    if (start < _minPrice) start = _minPrice;
    if (end > _maxPrice) end = _maxPrice;
    if (start > end) end = start;

    final next = RangeValues(start, end);

    setState(() {
      _state = _state.copyWith(priceRange: next);
    });

    if (syncText) {
      final startText = start.round().toString();
      final endText = end.round().toString();

      if (_minPriceController.text != startText) {
        _minPriceController.text = startText;
      }
      if (_maxPriceController.text != endText) {
        _maxPriceController.text = endText;
      }
    }
  }

  double? _parseMoney(String raw) {
    final s = raw.trim().replaceAll(' ', '').replaceAll(',', '.');
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }

  void _onMinChanged(String raw) {
    _priceDebounce?.cancel();
    _priceDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      final min = _parseMoney(raw);
      if (min == null) return;
      _setPriceRange(RangeValues(min, _state.priceRange.end), syncText: false);
    });
  }

  void _onMaxChanged(String raw) {
    _priceDebounce?.cancel();
    _priceDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      final max = _parseMoney(raw);
      if (max == null) return;
      _setPriceRange(RangeValues(_state.priceRange.start, max), syncText: false);
    });
  }

  void _reset() {
    setState(() {
      _state = const FilterState(
        selectedType: null,
        selectedSubtypes: <String>[],
        priceRange: RangeValues(_minPrice, _maxPrice),
        sortBy: 'newest',
      );
    });

    _minPriceController.text = _minPrice.round().toString();
    _maxPriceController.text = _maxPrice.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final lang = Localizations.localeOf(context).languageCode == 'uk'
        ? LotexLanguage.uk
        : LotexLanguage.en;

    final roots = CategoryI18n.roots(widget.categories);
    final selectedType = _state.selectedType;
    final subtypes = selectedType == null
        ? const <CategoryModel>[]
        : CategoryI18n.childrenOf(widget.categories, selectedType);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.18 * 255).round()),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    LotexI18n.tr(lang, 'filters'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: _reset,
                  child: Text(LotexI18n.tr(lang, 'reset')),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              LotexI18n.tr(lang, 'category'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(LotexI18n.tr(lang, 'all')),
                  selected: _state.selectedType == null && _state.selectedSubtypes.isEmpty,
                  onSelected: (_) => setState(
                    () => _state = _state.copyWith(clearType: true, clearSubtypes: true),
                  ),
                ),
                ...roots.map(
                  (c) => ChoiceChip(
                    label: Text(CategoryI18n.label(lang, c.id, fallback: c.name)),
                    selected: _state.selectedType == c.id,
                    onSelected: (_) => setState(
                      () => _state = _state.copyWith(
                        selectedType: c.id,
                        clearSubtypes: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (selectedType != null && subtypes.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                LotexI18n.tr(lang, 'subtypes'),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: Text(LotexI18n.tr(lang, 'any')),
                    selected: _state.selectedSubtypes.isEmpty,
                    onSelected: (_) => setState(() => _state = _state.copyWith(clearSubtypes: true)),
                  ),
                  ...subtypes.map((c) {
                    final isSelected = _state.selectedSubtypes.contains(c.id);
                    return FilterChip(
                      label: Text(CategoryI18n.label(lang, c.id, fallback: c.name)),
                      selected: isSelected,
                      onSelected: (_) {
                        final next = List<String>.from(_state.selectedSubtypes);
                        if (isSelected) {
                          next.remove(c.id);
                        } else {
                          next.add(c.id);
                        }
                        setState(() => _state = _state.copyWith(selectedSubtypes: next));
                      },
                    );
                  }),
                ],
              ),
            ],

            const SizedBox(height: 16),
            Text(
              LotexI18n.tr(lang, 'price'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9\s\.,]')),
                    ],
                    onChanged: _onMinChanged,
                    onEditingComplete: () {
                      _priceDebounce?.cancel();
                      final min = _parseMoney(_minPriceController.text);
                      if (min == null) {
                        _minPriceController.text = _state.priceRange.start.round().toString();
                        FocusScope.of(context).unfocus();
                        return;
                      }
                      _setPriceRange(RangeValues(min, _state.priceRange.end));
                      FocusScope.of(context).unfocus();
                    },
                    decoration: InputDecoration(
                      labelText: LotexI18n.tr(lang, 'min'),
                      suffixText: '₴',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _maxPriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9\s\.,]')),
                    ],
                    onChanged: _onMaxChanged,
                    onEditingComplete: () {
                      _priceDebounce?.cancel();
                      final max = _parseMoney(_maxPriceController.text);
                      if (max == null) {
                        _maxPriceController.text = _state.priceRange.end.round().toString();
                        FocusScope.of(context).unfocus();
                        return;
                      }
                      _setPriceRange(RangeValues(_state.priceRange.start, max));
                      FocusScope.of(context).unfocus();
                    },
                    decoration: InputDecoration(
                      labelText: LotexI18n.tr(lang, 'max'),
                      suffixText: '₴',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            RangeSlider(
              values: _state.priceRange,
              min: _minPrice,
              max: _maxPrice,
              divisions: 200,
              labels: RangeLabels(
                '${_state.priceRange.start.round()} ₴',
                '${_state.priceRange.end.round()} ₴',
              ),
              onChanged: (v) => _setPriceRange(v),
            ),

            const SizedBox(height: 12),
            Text(
              LotexI18n.tr(lang, 'sort'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              key: ValueKey(_state.sortBy),
              initialValue: _state.sortBy,
              items: [
                DropdownMenuItem(
                  value: 'newest',
                  child: Text(LotexI18n.tr(lang, 'sortNewest')),
                ),
                DropdownMenuItem(
                  value: 'price_asc',
                  child: Text(LotexI18n.tr(lang, 'sortPriceAsc')),
                ),
                DropdownMenuItem(
                  value: 'price_desc',
                  child: Text(LotexI18n.tr(lang, 'sortPriceDesc')),
                ),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => _state = _state.copyWith(sortBy: v));
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_state),
                child: Text(
                  LotexI18n.tr(lang, 'apply'),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
