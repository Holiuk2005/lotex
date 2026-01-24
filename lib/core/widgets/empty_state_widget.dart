import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? imageAsset;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.icon,
    this.imageAsset,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final color = Colors.white70;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageAsset != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Image.asset(imageAsset!, width: 120, height: 120, fit: BoxFit.contain),
              )
            else
              Icon(icon ?? Icons.inbox_rounded, size: 96, color: color),
            const SizedBox(height: 18),
            Text(title, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 14),
              ElevatedButton(onPressed: onButtonPressed, child: Text(buttonText!)),
            ],
          ],
        ),
      ),
    );
  }
}
