import 'dart:convert'; // Для Apple Sign In (crypto)
import 'dart:math';    // Для Apple Sign In (nonce)
import 'package:crypto/crypto.dart'; // Для Apple Sign In (sha256)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../domain/entities/user_entity.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(FirebaseAuth.instance));

class AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Ініціалізація Google

  AuthRepository(this._auth);

  // 1. Потік стану
  Stream<UserEntity?> get authStateChanges {
    // Use userChanges() so profile updates (displayName/photoURL) also emit
    return _auth.userChanges().map((user) {
      if (user == null) return null;
      return UserEntity.fromFirebaseUser(user);
    });
  }

  // 2. Email/Password Реєстрація
  Future<UserEntity> signUp({required String email, required String password}) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (userCredential.user == null) throw Exception('Помилка реєстрації');
    return UserEntity.fromFirebaseUser(userCredential.user!);
  }

  // 3. Email/Password Вхід
  Future<UserEntity> signIn({required String email, required String password}) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (userCredential.user == null) throw Exception('Помилка входу');
    return UserEntity.fromFirebaseUser(userCredential.user!);
  }

  // --- НОВЕ: Вхід через Google ---
  Future<UserEntity> signInWithGoogle() async {
    try {
      // Запуск потоку входу Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Вхід скасовано користувачем');

      // Отримання токенів
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Вхід у Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user == null) throw Exception('Помилка входу через Google');
      return UserEntity.fromFirebaseUser(userCredential.user!);
    } catch (e) {
      throw Exception('Помилка Google Sign In: $e');
    }
  }

  // --- НОВЕ: Вхід через Apple ---
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
      if (userCredential.user == null) throw Exception('Помилка входу через Apple');
      return UserEntity.fromFirebaseUser(userCredential.user!);
    } catch (e) {
      throw Exception('Помилка Apple Sign In: $e');
    }
  }

  // 4. Вихід
  Future<void> signOut() async {
    await _googleSignIn.signOut(); // Вихід з Google теж
    await _auth.signOut();
  }

  UserEntity? get currentUser {
    final user = _auth.currentUser;
    return user != null ? UserEntity.fromFirebaseUser(user) : null;
  }

  // Допоміжні методи для Apple Sign In
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

}
// ------------------ Providers & Controller ------------------

// Потік стану авторизації (для AppRouter)
final authStateChangesProvider = StreamProvider<UserEntity?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

// Поточний користувач без стріму
final currentUserProvider = Provider<UserEntity?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.currentUser;
});

// Контролер для виконання дій (signIn/signUp/signOut)
final authControllerProvider = AsyncNotifierProvider<AuthController, void>(AuthController.new);

class AuthController extends AsyncNotifier<void> {
  late final AuthRepository _repository;

  @override
  Future<void> build() async {
    _repository = ref.read(authRepositoryProvider);
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      await _repository.signIn(email: email, password: password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      await _repository.signUp(email: email, password: password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _repository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      await _repository.signInWithGoogle();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();
    try {
      await _repository.signInWithApple();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
