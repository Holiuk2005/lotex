import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_manager.dart';

class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use ThemeManager to toggle theme globally
    final mode = ThemeManager.mode.value;
    return IconButton(
      icon: Icon(mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
      tooltip: 'Toggle theme',
      onPressed: () => ThemeManager.toggle(),
    );
  }
}
