import 'package:intl/intl.dart';
import 'dart:collection';

class LotexCurrency {
  static const String uah = 'UAH';
  static const String usd = 'USD';
  static const String eur = 'EUR';

  static const List<String> supported = [uah, usd, eur];

  static int defaultDecimalDigits(String code) {
    switch (code) {
      case uah:
        return 0;
      case usd:
      case eur:
        return 2;
      default:
        return 2;
    }
  }

  static String symbol(String code) {
    switch (code) {
      case uah:
        return '₴';
      case usd:
        return r'$';
      case eur:
        return '€';
      default:
        return code;
    }
  }

  // Simple LRU cache for currency formatters.
  // Formatting is called frequently during list rebuilds; caching avoids repeated
  // NumberFormat allocations and improves smoothness on Web and mobile.
  static final LinkedHashMap<String, NumberFormat> _formatterCache = LinkedHashMap();
  static int maxCachedFormatters = 48;

  static String _key(String localeName, String code, int digits) => '$localeName|$code|$digits';

  static void _touch(String key, NumberFormat fmt) {
    _formatterCache.remove(key);
    _formatterCache[key] = fmt;
    while (_formatterCache.length > maxCachedFormatters) {
      _formatterCache.remove(_formatterCache.keys.first);
    }
  }

  static NumberFormat formatter({
    required String localeName,
    required String code,
    int? decimalDigits,
  }) {
    final digits = decimalDigits ?? defaultDecimalDigits(code);
    final key = _key(localeName, code, digits);
    final existing = _formatterCache[key];
    if (existing != null) {
      _touch(key, existing);
      return existing;
    }

    final created = NumberFormat.currency(
      locale: localeName,
      name: code,
      symbol: symbol(code),
      decimalDigits: digits,
    );
    _touch(key, created);
    return created;
  }
}
