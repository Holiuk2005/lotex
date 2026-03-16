import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

/// Малий LRU-кеш для декодованих base64-зображень.
///
/// Декодування base64 під час ребілдів списків/сіток може спричиняти
/// затримки на web та слабких пристроях. Кеш зберігає обмежену кількість
/// декодованих буферів у пам'яті.
class Base64ImageCache {
  static final LinkedHashMap<String, Uint8List> _cache = LinkedHashMap();

  /// Налаштовуваний ліміт. Тримаємо консервативно, щоб уникнути надмірного споживання пам'яті.
  static int maxEntries = 40;

  static String _stripDataUri(String input) {
    final s = input.trim();
    if (!s.startsWith('data:')) return s;
    final comma = s.indexOf(',');
    if (comma < 0) return s;
    return s.substring(comma + 1);
  }

  static String _cacheKey(String payload, {String? cacheKey}) {
    // Повний base64 не зберігаємо як ключ — він завеликий.
    // hashCode залежить від запуску, але для in-memory кешу це нормально.
    final safe = payload.length > 32 ? payload.substring(0, 32) : payload;
    return cacheKey ?? '${payload.length}:${payload.hashCode}:$safe';
  }

  static void _touch(String key, Uint8List bytes) {
    _cache.remove(key);
    _cache[key] = bytes;
    while (_cache.length > maxEntries) {
      _cache.remove(_cache.keys.first);
    }
  }

  /// Повертає декодовані байти або null, якщо вхідні дані некоректні.
  static Uint8List? decode(String base64, {String? cacheKey}) {
    final payload = _stripDataUri(base64);
    if (payload.isEmpty) return null;

    final key = _cacheKey(payload, cacheKey: cacheKey);
    final existing = _cache[key];
    if (existing != null) {
      _touch(key, existing);
      return existing;
    }

    try {
      final bytes = base64Decode(payload);
      _touch(key, bytes);
      return bytes;
    } catch (_) {
      return null;
    }
  }

  static void clear() => _cache.clear();
}
