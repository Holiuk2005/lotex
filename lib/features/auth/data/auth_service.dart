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

  /// Creates an auth user and immediately persists a matching Firestore user doc.
  ///
  /// Firestore doc path: users/{uid}
  /// Fields: uid, email, username, role (default 'user'), balance (default 0.0), createdAt.
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
      // Best-effort cleanup to avoid "auth user without profile".
      try {
        await user.delete();
      } catch (_) {
        // ignore
      }

      throw Exception(_friendlyFirestoreError(e));
    } catch (_) {
      try {
        await user.delete();
      } catch (_) {
        // ignore
      }

      throw Exception('Failed to save user profile. Please try again.');
    }
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email already in use.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'operation-not-allowed':
        return 'Email/password sign up is disabled.';
      case 'network-request-failed':
        return 'Network error. Please try again.';
      default:
        // Keep a clean message for unknown auth errors.
        return 'Sign up failed. Please try again.';
    }
  }

  String _friendlyFirestoreError(FirebaseException e) {
    // Firestore uses e.code like "permission-denied", "unavailable", etc.
    switch (e.code) {
      case 'permission-denied':
        return 'Permission denied. Check Firestore rules.';
      case 'unavailable':
        return 'Service unavailable. Please try again.';
      default:
        return 'Failed to save user profile. Please try again.';
    }
  }
}
