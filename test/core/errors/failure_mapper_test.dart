import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotex/core/errors/failure.dart';
import 'package:lotex/core/errors/failure_mapper.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;

/// Stub FirebaseException для тестів
FirebaseException _fe(String code, [String? msg]) =>
    FirebaseException(plugin: 'firestore', code: code, message: msg);

fa.FirebaseAuthException _fae(String code) =>
    fa.FirebaseAuthException(code: code);

void main() {
  group('FailureMapper', () {
    test('permission-denied → PermissionDeniedFailure', () {
      final f = FailureMapper.from(_fe('permission-denied'));
      expect(f, isA<PermissionDeniedFailure>());
    });

    test('not-found → NotFoundFailure', () {
      final f = FailureMapper.from(_fe('not-found'));
      expect(f, isA<NotFoundFailure>());
    });

    test('unauthenticated → AuthRequiredFailure', () {
      final f = FailureMapper.from(_fe('unauthenticated'));
      expect(f, isA<AuthRequiredFailure>());
    });

    test('requires-recent-login → AuthRequiredFailure', () {
      final f = FailureMapper.from(_fe('requires-recent-login'));
      expect(f, isA<AuthRequiredFailure>());
    });

    test('unavailable → NetworkFailure', () {
      final f = FailureMapper.from(_fe('unavailable'));
      expect(f, isA<NetworkFailure>());
    });

    test('deadline-exceeded → NetworkFailure', () {
      final f = FailureMapper.from(_fe('deadline-exceeded'));
      expect(f, isA<NetworkFailure>());
    });

    test('failed-precondition з message → ValidationFailure', () {
      final f = FailureMapper.from(_fe('failed-precondition', 'Тест помилки'));
      expect(f, isA<ValidationFailure>());
    });

    test('невідомий код → UnknownFailure', () {
      final f = FailureMapper.from(_fe('custom-error', 'something'));
      expect(f, isA<UnknownFailure>());
    });

    test('вже є Failure → повертається без змін', () {
      const original = NetworkFailure();
      final f = FailureMapper.from(original);
      expect(identical(f, original), isTrue);
    });

    test('мережева помилка (текст "network") → NetworkFailure', () {
      final f = FailureMapper.from(Exception('network error'));
      expect(f, isA<NetworkFailure>());
    });

    test('помилка timeout → NetworkFailure', () {
      final f = FailureMapper.from(Exception('Request timeout'));
      expect(f, isA<NetworkFailure>());
    });

    test('FirebaseAuthException permission-denied → PermissionDeniedFailure', () {
      final f = FailureMapper.from(_fae('permission-denied'));
      expect(f, isA<PermissionDeniedFailure>());
    });
  });
}
