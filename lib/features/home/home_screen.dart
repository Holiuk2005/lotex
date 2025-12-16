import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/product_card.dart';
import 'package:lotex/core/widgets/theme_toggle.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(_fade);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Знайди те, що потрібно', style: AppTextStyles.h1),
        actions: const [ThemeToggle()],
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: const [
              ProductCard(heroTag: 'product_1', title: 'iPhone 13 Pro Max', price: '25 000 ₴'),
              ProductCard(heroTag: 'product_2', title: 'MacBook Pro 14"', price: '75 000 ₴'),
              ProductCard(heroTag: 'product_3', title: 'Sony WH-1000XM5', price: '8 500 ₴'),
            ],
          ),
        ),
      ),
    );
  }
}
