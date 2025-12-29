import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lotex/features/auth/data/firebase_auth_datasource.dart';
import 'package:lotex/features/auth/domain/auth_repository.dart';
import 'package:lotex/features/auth/domain/entities/user_entity.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource datasource;
  final FirebaseFirestore firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl(this.datasource, this.firestore)
      : _googleSignIn = GoogleSignIn();

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
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign in cancelled');
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
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
    if (await _googleSignIn.isSignedIn()) await _googleSignIn.signOut();
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
    await firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'name': name ?? '',
      'photoUrl': photoUrl ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
