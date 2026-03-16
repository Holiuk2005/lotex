import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

String humanError(Object error) {
  // Flutter web може загортати async-винятки в AsyncError з повідомленням:
  // "Dart exception thrown from converted Future...".
  if (error is AsyncError) {
    return humanError(error.error);
  }

  // На Flutter web деякі async-помилки виникають як об'єкти, чий `toString()` є:
  // "Error: Dart exception thrown from converted Future...".
  // Ці об'єкти зазвичай містять реальну помилку у властивості `error`.
  try {
    final dynamic dyn = error;
    final Object? inner = dyn.error as Object?;
    if (inner != null && !identical(inner, error)) {
      return humanError(inner);
    }
  } catch (_) {
    // Ігноруємо, якщо властивість `error` не існує.
  }

  if (error is FirebaseException) {
    final msg = error.message;
    if (msg != null && msg.trim().isNotEmpty) return msg.trim();
    if (error.code.trim().isNotEmpty) return error.code.trim();
    return 'Firebase error';
  }

  var text = error.toString();
  if (text.startsWith('Exception: ')) {
    text = text.substring('Exception: '.length);
  }
  if (text.startsWith('Error: ')) {
    text = text.substring('Error: '.length);
  }

  // Якщо дійшли сюди з web-wrapper повідомленням — показуємо чистий fallback.
  if (text.contains('Dart exception thrown from converted Future')) {
    return 'Невідома помилка. Спробуйте перезавантажити сторінку та повторити дію.';
  }

  return text;
}
