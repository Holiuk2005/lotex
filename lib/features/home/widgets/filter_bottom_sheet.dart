import 'package:flutter/material.dart';

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

  static const double _minPrice = 0;
  static const double _maxPrice = 100000;

  @override
  void initState() {
    super.initState();
    _state = widget.initial;
  }

  void _reset() {
    setState(() {
      _state = const FilterState(
        selectedCategory: null,
        priceRange: RangeValues(_minPrice, _maxPrice),
        sortBy: 'newest',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

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
                    'Фільтри',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: _reset,
                  child: const Text('Скинути'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              'Категорія',
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
                  label: const Text('Усі'),
                  selected: _state.selectedCategory == null,
                  onSelected: (_) => setState(() => _state = _state.copyWith(clearCategory: true)),
                ),
                ...widget.categories.map(
                  (c) => ChoiceChip(
                    label: Text(c.name),
                    selected: _state.selectedCategory == c.id,
                    onSelected: (_) => setState(() => _state = _state.copyWith(selectedCategory: c.id)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Text(
              'Ціна',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('${_state.priceRange.start.round()} ₴'),
                const Spacer(),
                Text('${_state.priceRange.end.round()} ₴'),
              ],
            ),
            RangeSlider(
              values: _state.priceRange,
              min: _minPrice,
              max: _maxPrice,
              divisions: 200,
              labels: RangeLabels(
                '${_state.priceRange.start.round()} ₴',
                '${_state.priceRange.end.round()} ₴',
              ),
              onChanged: (v) => setState(() => _state = _state.copyWith(priceRange: v)),
            ),

            const SizedBox(height: 12),
            Text(
              'Сортування',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              key: ValueKey(_state.sortBy),
              initialValue: _state.sortBy,
              items: const [
                DropdownMenuItem(value: 'newest', child: Text('Найновіші')),
                DropdownMenuItem(value: 'price_asc', child: Text('Ціна: спочатку дешевші')),
                DropdownMenuItem(value: 'price_desc', child: Text('Ціна: спочатку дорожчі')),
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
                child: const Text('Застосувати', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
