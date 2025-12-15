import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(FirebaseAuth.instance));

class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository(this._auth);

  // 1. Потік стану авторизації (для AppRouter)
  Stream<UserEntity?> get authStateChanges {
    // Перетворюємо Firebase User на наш UserEntity
    return _auth.authStateChanges().map((user) {
      if (user == null) {
        return null;
      }
      return UserEntity.fromFirebaseUser(user);
    });
  }

  // 2. Реєстрація
  Future<UserEntity> signUp({required String email, required String password}) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (userCredential.user == null) throw Exception('Помилка реєстрації');
    return UserEntity.fromFirebaseUser(userCredential.user!);
  }

  // 3. Вхід
  Future<UserEntity> signIn({required String email, required String password}) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (userCredential.user == null) throw Exception('Помилка входу');
    return UserEntity.fromFirebaseUser(userCredential.user!);
  }

  // 4. Вихід
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // 5. Поточний користувач (для репозиторіїв)
  UserEntity? get currentUser {
    final user = _auth.currentUser;
    return user != null ? UserEntity.fromFirebaseUser(user) : null;
  }
}