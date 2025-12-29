import 'package:lotex/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> authStateChanges();

  Future<UserEntity> signUp({required String email, required String password});

  Future<UserEntity> signIn({required String email, required String password});

  Future<UserEntity> signInWithGoogle();

  Future<UserEntity> signInWithApple();

  Future<void> signOut();

  UserEntity? get currentUser;
}
