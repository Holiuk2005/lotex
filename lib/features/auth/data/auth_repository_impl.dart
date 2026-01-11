import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lotex/features/auth/data/firebase_auth_datasource.dart';
import 'package:lotex/features/auth/domain/auth_repository.dart';
import 'package:lotex/features/auth/domain/entities/user_entity.dart';
import 'package:lotex/services/secure_storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource datasource;
  final FirebaseFirestore firestore;

  static Future<void>? _googleInit;

  static const String _googleWebClientId =
      '823233113152-iktaaoltbruf2o3uhmu0d3rjp80qnju1.apps.googleusercontent.com';

  AuthRepositoryImpl(this.datasource, this.firestore);

  Future<void> _ensureGoogleInitialized() {
    return _googleInit ??= GoogleSignIn.instance.initialize(
      clientId: kIsWeb ? _googleWebClientId : null,
      serverClientId: kIsWeb ? null : _googleWebClientId,
    );
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return datasource.authStateChanges().map(
      (user) => user == null ? null : UserEntity.fromFirebaseUser(user),
    );
  }

  @override
  Future<UserEntity> signUp({required String email, required String password}) async {
    final cred = await datasource.signUp(email, password);
    final user = cred.user;
    if (user == null) throw Exception('Sign up failed');
    await _saveUserData(uid: user.uid, email: email);
    return UserEntity.fromFirebaseUser(user);
  }

  @override
  Future<UserEntity> signIn({required String email, required String password}) async {
    final cred = await datasource.signIn(email, password);
    final user = cred.user;
    if (user == null) throw Exception('Sign in failed');
    return UserEntity.fromFirebaseUser(user);
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      final cred = await FirebaseAuth.instance.signInWithPopup(provider);
      final user = cred.user;
      if (user == null) throw Exception('Google sign in failed');
      await _saveUserData(
        uid: user.uid,
        email: user.email ?? '',
        name: user.displayName,
        photoUrl: user.photoURL,
      );
      return UserEntity.fromFirebaseUser(user);
    }

    await _ensureGoogleInitialized();

    final googleUser = await GoogleSignIn.instance.authenticate();
    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);
    final cred = await datasource.signInWithCredential(credential);
    final user = cred.user;
    if (user == null) throw Exception('Google sign in failed');
    await _saveUserData(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName,
      photoUrl: user.photoURL,
    );
    return UserEntity.fromFirebaseUser(user);
  }

  @override
  Future<UserEntity> signInWithApple() async {
    throw UnimplementedError('Apple sign-in is not implemented in this repository');
  }

  @override
  Future<void> signOut() async {
    if (!kIsWeb) {
      await _ensureGoogleInitialized();
      await GoogleSignIn.instance.signOut();
    }
    await SecureStorageService.deleteAllTokens();
    await datasource.signOut();
  }

  @override
  UserEntity? get currentUser =>
      datasource.currentUser == null ? null : UserEntity.fromFirebaseUser(datasource.currentUser);

  Future<void> _saveUserData({
    required String uid,
    required String email,
    String? name,
    String? photoUrl,
  }) async {
    // Private profile (owner-only read)
    await firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Public profile (readable by anyone)
    await firestore.collection('public_profiles').doc(uid).set({
      'displayName': (name ?? '').trim(),
      'photoURL': (photoUrl ?? '').trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
