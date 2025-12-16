import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppButtonStyle { primary, secondary }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final bool enabled;

  const AppButton.primary({super.key, required this.label, required this.onPressed})
      : style = AppButtonStyle.primary,
        enabled = true;

  const AppButton.secondary({super.key, required this.label, required this.onPressed})
      : style = AppButtonStyle.secondary,
        enabled = true;

  const AppButton.disabled({super.key, required this.label})
      : style = AppButtonStyle.primary,
        onPressed = null,
        enabled = false;

  Color _bgColor(BuildContext context) {
    if (!enabled) return Colors.grey.shade300;
    return style == AppButtonStyle.primary ? AppColors.primary : Theme.of(context).cardColor;
  }

  Color _textColor(BuildContext context) {
    if (!enabled) return Colors.grey.shade600;
    return style == AppButtonStyle.primary ? Colors.white : AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _bgColor(context),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          foregroundColor: _textColor(context),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

}
