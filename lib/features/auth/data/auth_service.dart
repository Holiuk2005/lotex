import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Створює auth-користувача та відразу зберігає відповідний документ у Firestore.
  ///
  /// Шлях документа Firestore: users/{uid}
  /// Поля: uid, email, username, role (за замовчуванням 'user'), balance (за замовчуванням 0.0), createdAt.
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final normalizedEmail = email.trim();
    final normalizedUsername = username.trim();

    if (normalizedUsername.isEmpty) {
      throw Exception('Username is required');
    }

    UserCredential cred;
    try {
      cred = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e));
    } catch (_) {
      throw Exception('Sign up failed. Please try again.');
    }

    final user = cred.user;
    if (user == null) {
      throw Exception('Sign up failed. Please try again.');
    }

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': normalizedEmail,
        'username': normalizedUsername,
        'role': 'user',
        'balance': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      // Спроба очищення, щоб не залишати auth-користувача без профілю.
      try {
        await user.delete();
      } catch (_) {
        // ігноруємо
      }

      throw Exception(_friendlyFirestoreError(e));
    } catch (_) {
      try {
        await user.delete();
      } catch (_) {
        // ігноруємо
      }

      throw Exception('Failed to save user profile. Please try again.');
    }
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email вже використовується.';
      case 'invalid-email':
        return 'Невірна адреса електронної пошти.';
      case 'weak-password':
        return 'Пароль занадто слабкий.';
      case 'operation-not-allowed':
        return 'Реєстрація через email/пароль вимкнена.';
      case 'network-request-failed':
        return 'Помилка мережі. Спробуйте ще раз.';
      default:
        // Чисте повідомлення для невідомих auth-помилок.
        return 'Не вдалось зареєструватись. Спробуйте ще раз.';
    }
  }

  String _friendlyFirestoreError(FirebaseException e) {
    // Firestore використовує e.code як: "permission-denied", "unavailable" тощо.
    switch (e.code) {
      case 'permission-denied':
        return 'Доступ заборонено. Перевірте правила Firestore.';
      case 'unavailable':
        return 'Сервіс недоступний. Спробуйте ще раз.';
      default:
        return 'Не вдалось зберегти профіль. Спробуйте ще раз.';
    }
  }
}
