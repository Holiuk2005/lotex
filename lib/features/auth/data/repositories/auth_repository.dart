import 'dart:convert'; // Для генерації nonce (Apple)
import 'dart:math';    // Для генерації nonce (Apple)
import 'package:crypto/crypto.dart'; // Для хешування nonce (Apple)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../domain/entities/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(FirebaseAuth.instance));

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- НАЛАШТУВАННЯ GOOGLE SIGN IN ---
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  Future<void>? _googleInit;

  static const String _googleWebClientId =
      '823233113152-iktaaoltbruf2o3uhmu0d3rjp80qnju1.apps.googleusercontent.com';

  AuthRepository(this._auth);

  Future<void> _ensureGoogleInitialized() {
    return _googleInit ??= _googleSignIn.initialize(
      clientId: kIsWeb ? _googleWebClientId : null,
      serverClientId: kIsWeb ? null : _googleWebClientId,
    );
  }

  // 1. Потік стану авторизації
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserEntity.fromFirebaseUser(user);
    });
  }

  // 2. Реєстрація (Email)
  Future<UserEntity> signUp({required String email, required String password}) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (userCredential.user == null) throw Exception('Помилка реєстрації');

    // Зберегти базові дані в Firestore
    await saveUserData(uid: userCredential.user!.uid, email: email);

    return UserEntity.fromFirebaseUser(userCredential.user!);
  }

  // 3. Вхід (Email)
  Future<UserEntity> signIn({required String email, required String password}) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (userCredential.user == null) throw Exception('Помилка входу');
    return UserEntity.fromFirebaseUser(userCredential.user!);
  }

  // --- 4. Вхід через GOOGLE ---
  Future<UserEntity> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();

      // Запуск інтерактивної авторизації
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // Отримання токенів (google_sign_in 7.x повертає лише idToken)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Створення credential для Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Вхід у Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) throw Exception('Помилка Google входу');

      // Зберегти/оновити дані в Firestore
      await saveUserData(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email ?? '',
        name: userCredential.user!.displayName,
        photoUrl: userCredential.user!.photoURL,
      );

      return UserEntity.fromFirebaseUser(userCredential.user!);
    } catch (e) {
      throw Exception('Помилка Google Sign In: $e');
    }
  }

  // --- 5. Вхід через APPLE ---
  Future<UserEntity> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Запит до Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Створення credential для Firebase
      final OAuthCredential credential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
        rawNonce: rawNonce,
      );

      // Вхід у Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) throw Exception('Помилка Apple Sign In');

      // Зберегти/оновити дані в Firestore
      await saveUserData(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email ?? '',
        name: userCredential.user!.displayName,
        photoUrl: userCredential.user!.photoURL,
      );

      return UserEntity.fromFirebaseUser(userCredential.user!);
    } catch (e) {
      throw Exception('Помилка Apple Sign In: $e');
    }
  }

  // 6. Вихід
  Future<void> signOut() async {
    await _ensureGoogleInitialized();
    // Важливо вийти з Google теж, щоб при наступному вході можна було вибрати інший акаунт
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // 7. Поточний користувач
  UserEntity? get currentUser {
    final user = _auth.currentUser;
    return user != null ? UserEntity.fromFirebaseUser(user) : null;
  }

  // --- Допоміжні методи для Apple Sign In ---
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Метод для збереження даних користувача в базу
  Future<void> saveUserData({
    required String uid,
    required String email,
    String? name,
    String? photoUrl,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _firestore.collection('public_profiles').doc(uid).set({
        'displayName': (name ?? '').trim(),
        'photoURL': (photoUrl ?? '').trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Не вдалося зберегти профіль: $e');
    }
  }
}