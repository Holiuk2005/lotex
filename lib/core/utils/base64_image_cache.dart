import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

/// Small LRU cache for decoded base64 images.
///
/// Decoding base64 during list/grid rebuilds can cause jank on Web and low-end
/// devices. This cache keeps a limited number of decoded byte buffers in memory.
class Base64ImageCache {
  static final LinkedHashMap<String, Uint8List> _cache = LinkedHashMap();

  /// Tuneable limit. Keep it conservative to avoid memory bloat.
  static int maxEntries = 40;

  static String _stripDataUri(String input) {
    final s = input.trim();
    if (!s.startsWith('data:')) return s;
    final comma = s.indexOf(',');
    if (comma < 0) return s;
    return s.substring(comma + 1);
  }

  static String _cacheKey(String payload, {String? cacheKey}) {
    // Do not store full base64 payload as key; it's large.
    // hashCode is per-run, but that's fine for an in-memory cache.
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

  /// Returns decoded bytes or null if input is invalid.
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
