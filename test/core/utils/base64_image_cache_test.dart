import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lotex/core/utils/base64_image_cache.dart';

void main() {
  setUp(() {
    Base64ImageCache.clear();
    Base64ImageCache.maxEntries = 10;
  });

  test('decode returns cached bytes for same key', () {
    final raw = Uint8List.fromList(List<int>.generate(16, (i) => i));
    final b64 = base64Encode(raw);

    final a = Base64ImageCache.decode(b64, cacheKey: 'k');
    final b = Base64ImageCache.decode(b64, cacheKey: 'k');

    expect(a, isNotNull);
    expect(b, isNotNull);
    expect(identical(a, b), isTrue);
    expect(a, equals(raw));
  });

  test('decode supports data URI prefix', () {
    final raw = Uint8List.fromList([1, 2, 3, 4, 5]);
    final b64 = 'data:image/png;base64,${base64Encode(raw)}';

    final bytes = Base64ImageCache.decode(b64, cacheKey: 'dataUri');
    expect(bytes, equals(raw));
  });

  test('decode returns null for invalid base64', () {
    final bytes = Base64ImageCache.decode('not base64!!!', cacheKey: 'bad');
    expect(bytes, isNull);
  });
}
