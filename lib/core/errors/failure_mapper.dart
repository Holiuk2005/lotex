import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;

import 'failure.dart';

class FailureMapper {
  static Failure from(Object error) {
    if (error is Failure) return error;

    if (error is fa.FirebaseAuthException) {
      return _fromCode(error.code, error.message);
    }

    if (error is FirebaseException) {
      return _fromCode(error.code, error.message);
    }

    // Heuristic for common web/IO network-ish failures.
    final text = error.toString().toLowerCase();
    if (text.contains('network') ||
        text.contains('socket') ||
        text.contains('timeout')) {
      return const NetworkFailure();
    }

    return UnknownFailure(error);
  }

  static Failure _fromCode(String code, String? message) {
    switch (code) {
      case 'permission-denied':
        return const PermissionDeniedFailure();
      case 'not-found':
        return const NotFoundFailure();
      case 'unauthenticated':
      case 'requires-recent-login':
        return const AuthRequiredFailure();
      case 'unavailable':
      case 'deadline-exceeded':
        return const NetworkFailure();
      case 'failed-precondition':
      case 'invalid-argument':
        return ValidationFailure((message ?? '').trim());
      default:
        return UnknownFailure(
            message?.trim().isNotEmpty == true ? message!.trim() : code);
    }
  }
}
