import 'package:flutter/services.dart';

/// Formats credit card numbers as `1234 5678 9012 3456`.
/// - Inserts a space after every 4 digits.
/// - Limits digits to 16 (19 chars including spaces).
class CardNumberFormatter extends TextInputFormatter {
  static const int _maxDigits = 16;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final oldText = oldValue.text;
    final newText = newValue.text;

    // Keep only digits
    final digitsOnly = newText.replaceAll(RegExp(r'\D'), '');
    final truncated = digitsOnly.length > _maxDigits ? digitsOnly.substring(0, _maxDigits) : digitsOnly;

    // Build spaced string
    final buffer = StringBuffer();
    for (var i = 0; i < truncated.length; i++) {
      if (i != 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(truncated[i]);
    }
    final formatted = buffer.toString();

    // Calculate new cursor position
    int selectionIndex = newValue.selection.end;
    // Count digits to the left of the cursor in the new value
    final digitsBeforeCursor = newText.substring(0, selectionIndex).replaceAll(RegExp(r'\D'), '').length;
    // Map digit index to formatted index
    int newCursorPosition = digitsBeforeCursor + (digitsBeforeCursor ~/ 4);
    if (newCursorPosition > formatted.length) newCursorPosition = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }
}

// Backwards-compatible alias for older imports
class CardNumberInputFormatter extends CardNumberFormatter {}
