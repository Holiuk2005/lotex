import 'package:flutter/material.dart';

class ThemeManager {
  ThemeManager._();

  // Default to dark to match the Lotex UI/UX reference.
  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.dark);

  static void toggle() {
    mode.value = mode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}
