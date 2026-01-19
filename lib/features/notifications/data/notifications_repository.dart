import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/app_notification.dart';

class NotificationsRepository {
  final FirebaseFirestore _firestore;

  const NotificationsRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> _col(String uid) {
    return _firestore.collection('users').doc(uid).collection('notifications');
  }

  Stream<List<AppNotification>> watchLatest(String uid, {int limit = 30}) {
    return _col(uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(AppNotification.fromDoc).toList(growable: false));
  }

  Stream<int> watchUnreadCount(String uid, {int limit = 50}) {
    // Firestore doesn't have a free realtime count without aggregates.
    // We keep it cheap by limiting the unread query.
    return _col(uid)
        .where('read', isEqualTo: false)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Future<void> markRead(String uid, String notificationId, {required bool read}) {
    return _col(uid).doc(notificationId).update(<String, dynamic>{
      'read': read,
      'readAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAllRead(String uid) async {
    final snap = await _col(uid)
        .where('read', isEqualTo: false)
        .limit(200)
        .get();

    if (snap.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, <String, dynamic>{
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> setCategorySubscription({
    required String uid,
    required String category,
    required bool subscribed,
  }) {
    final normalized = category.trim();
    if (normalized.isEmpty) return Future<void>.value();

    return _firestore.collection('users').doc(uid).set(<String, dynamic>{
      'subscribedCategories': subscribed
          ? FieldValue.arrayUnion(<String>[normalized])
          : FieldValue.arrayRemove(<String>[normalized]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
