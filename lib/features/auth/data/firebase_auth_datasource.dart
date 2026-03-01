import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import 'package:lotex/core/errors/failure_mapper.dart';

class FirebaseAuthDatasource {
  final FirebaseAuth _auth;

  FirebaseAuthDatasource(this._auth);

  Stream<User?> authStateChanges() => _auth.userChanges();

  Future<UserCredential> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      developer.log('FirebaseAuthDatasource.signUp error: $e');
      throw FailureMapper.from(e);
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      developer.log('FirebaseAuthDatasource.signIn error: $e');
      throw FailureMapper.from(e);
    }
  }

  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    try {
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      developer.log('FirebaseAuthDatasource.signInWithCredential error: $e');
      throw FailureMapper.from(e);
    }
  }

  Future<void> signOut() async => _auth.signOut();

  User? get currentUser => _auth.currentUser;

  // --- PHONE VERIFICATION ---
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(FirebaseAuthException error) verificationFailed,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
    required void Function(PhoneAuthCredential credential) verificationCompleted,
    int? forceResendingToken,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      forceResendingToken: forceResendingToken,
      );
    } catch (e) {
      developer.log('FirebaseAuthDatasource.verifyPhoneNumber error: $e');
      throw FailureMapper.from(e);
    }
  }

  Future<UserCredential> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    try {
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      developer.log('FirebaseAuthDatasource.signInWithSmsCode error: $e');
      throw FailureMapper.from(e);
    }
  }

  // Helpers for Apple Sign In
  String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
