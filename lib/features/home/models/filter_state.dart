import 'package:flutter/material.dart';

@immutable
class FilterState {
  final String? selectedType; // root category id, null => any
  final List<String> selectedSubtypes; // subcategory ids, empty => any (or whole type)
  final RangeValues priceRange;
  final String sortBy; // newest | price_asc | price_desc

  const FilterState({
    this.selectedType,
    this.selectedSubtypes = const <String>[],
    this.priceRange = const RangeValues(0, 100000),
    this.sortBy = 'newest',
  });

  FilterState copyWith({
    String? selectedType,
    bool clearType = false,
    List<String>? selectedSubtypes,
    bool clearSubtypes = false,
    RangeValues? priceRange,
    String? sortBy,
  }) {
    return FilterState(
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      selectedSubtypes: clearSubtypes ? const <String>[] : (selectedSubtypes ?? this.selectedSubtypes),
      priceRange: priceRange ?? this.priceRange,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  static const FilterState defaults = FilterState();
}
