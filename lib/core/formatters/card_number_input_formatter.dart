import 'package:flutter/services.dart';

/// Форматує номери кредитних карток у форматі `1234 5678 9012 3456`.
/// - Вставляє пробіл після кожних 4 цифр.
/// - Обмежує кількість цифр до 16 (19 символів, включаючи пробіли).
class CardNumberFormatter extends TextInputFormatter {
  static const int _maxDigits = 16;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text;

    // Залишити тільки цифри
    final digitsOnly = newText.replaceAll(RegExp(r'\D'), '');
    final truncated = digitsOnly.length > _maxDigits ? digitsOnly.substring(0, _maxDigits) : digitsOnly;

    // Створити рядок із пробілами
    final buffer = StringBuffer();
    for (var i = 0; i < truncated.length; i++) {
      if (i != 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(truncated[i]);
    }
    final formatted = buffer.toString();

    // Обчислити нове положення курсора
    final int selectionIndex = newValue.selection.end;
    // Підрахувати кількість цифр ліворуч від курсора в новому значенні
    final digitsBeforeCursor = newText.substring(0, selectionIndex).replaceAll(RegExp(r'\D'), '').length;
    // Перетворити індекс цифри на відформатований індекс
    int newCursorPosition = digitsBeforeCursor + (digitsBeforeCursor ~/ 4);
    if (newCursorPosition > formatted.length) newCursorPosition = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }
}

// Псевдонім із зворотньою сумісністю для старих імпортів
class CardNumberInputFormatter extends CardNumberFormatter {}
