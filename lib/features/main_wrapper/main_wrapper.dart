import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class MainWrapper extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapper({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: AppColors.primary500.withAlpha((0.2 * 255).round()),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Головна', selectedIcon: Icon(Icons.home)),
          NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Обране', selectedIcon: Icon(Icons.favorite)),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'Створити лот', selectedIcon: Icon(Icons.add_circle)),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Чат', selectedIcon: Icon(Icons.chat_bubble)),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Профіль', selectedIcon: Icon(Icons.person)),
        ],
      ),
    );
  }
}