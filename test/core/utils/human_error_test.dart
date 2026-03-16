import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotex/core/utils/human_error.dart';

/// Stub FirebaseException
FirebaseException _fe(String code, [String? msg]) =>
    FirebaseException(plugin: 'firestore', code: code, message: msg);

void main() {
  group('humanError', () {
    test('FirebaseException з message → повертає message', () {
      final err = _fe('not-found', 'Лот не знайдено.');
      expect(humanError(err), 'Лот не знайдено.');
    });

    test('FirebaseException без message → повертає code', () {
      final err = FirebaseException(plugin: 'firestore', code: 'not-found');
      expect(humanError(err), 'not-found');
    });

    test('Exception: prefix видаляється', () {
      final err = Exception('Щось пішло не так');
      expect(humanError(err), 'Щось пішло не так');
    });

    test('Error: prefix видаляється', () {
      // Симулюємо через строку
      final result = humanError(
        _FakeError('Error: Невідома помилка'),
      );
      expect(result, 'Невідома помилка');
    });

    test('web-wrapper message → чистий fallback', () {
      final result = humanError(
        _FakeError('Dart exception thrown from converted Future'),
      );
      expect(result.isNotEmpty, isTrue);
      expect(result.contains('Спробуйте'), isTrue);
    });
  });
}

/// Допоміжний клас для симуляції помилки з довільним toString
class _FakeError implements Exception {
  final String _msg;
  const _FakeError(this._msg);
  @override
  String toString() => _msg;
}
