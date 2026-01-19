import 'package:flutter/material.dart';

@immutable
class FilterState {
  final String? selectedCategory; // null => All
  final RangeValues priceRange;
  final String sortBy; // newest | price_asc | price_desc

  const FilterState({
    this.selectedCategory,
    this.priceRange = const RangeValues(0, 100000),
    this.sortBy = 'newest',
  });

  FilterState copyWith({
    String? selectedCategory,
    bool clearCategory = false,
    RangeValues? priceRange,
    String? sortBy,
  }) {
    return FilterState(
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      priceRange: priceRange ?? this.priceRange,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  static const FilterState defaults = FilterState();
}
