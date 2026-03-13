import 'package:flutter/material.dart';

class ThemeManager {
  ThemeManager._();

  // За замовчуванням використовується темний режим, щоб відповідати еталону інтерфейсу та користувацького досвіду Lotex.
  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.dark);

  static void toggle() {
    mode.value = mode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}
