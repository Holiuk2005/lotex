import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Helper to fetch a document and handle permission-denied gracefully.
Future<DocumentSnapshot<Map<String, dynamic>>?> fetchDocSafely({
  required BuildContext context,
  required DocumentReference<Map<String, dynamic>> ref,
  bool showSnackOnPermissionDenied = true,
}) async {
  try {
    return await ref.get();
  } on FirebaseException catch (e) {
    if (e.code == 'permission-denied') {
      if (showSnackOnPermissionDenied) {
        final messenger = ScaffoldMessenger.maybeOf(context);
        messenger?.showSnackBar(const SnackBar(content: Text('У вас немає прав для перегляду цієї інформації')));
      }
      return null;
    }
    rethrow;
  }
}
