import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

String humanError(Object error) {
  // Flutter web may wrap async exceptions into an AsyncError that prints:
  // "Dart exception thrown from converted Future...".
  if (error is AsyncError) {
    return humanError(error.error);
  }

  // On Flutter web, some async failures surface as objects whose `toString()` is:
  // "Error: Dart exception thrown from converted Future...".
  // Those objects typically expose the real error via the `error` property.
  try {
    final dynamic dyn = error;
    final Object? inner = dyn.error as Object?;
    if (inner != null && !identical(inner, error)) {
      return humanError(inner);
    }
  } catch (_) {
    // Ignore if `error` property does not exist.
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

  // If we still ended up here with the web wrapper message, show a cleaner fallback.
  if (text.contains('Dart exception thrown from converted Future')) {
    return 'Невідома помилка. Спробуйте перезавантажити сторінку та повторити дію.';
  }

  return text;
}
