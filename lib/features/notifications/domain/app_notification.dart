import 'package:cloud_firestore/cloud_firestore.dart';

/// In-app notification shown under the bell icon.
class AppNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;

  // Optional linking
  final String? auctionId;
  final String? category;
  final String? actorUid;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
    this.auctionId,
    this.category,
    this.actorUid,
  });

  factory AppNotification.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};

    DateTime parseCreatedAt(dynamic raw) {
      if (raw is Timestamp) return raw.toDate();
      if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
      return DateTime.now();
    }

    return AppNotification(
      id: doc.id,
      type: (data['type'] as String?)?.trim() ?? 'generic',
      title: (data['title'] as String?)?.trim() ?? 'Сповіщення',
      body: (data['body'] as String?)?.trim() ?? '',
      read: (data['read'] as bool?) ?? false,
      createdAt: parseCreatedAt(data['createdAt']),
      auctionId: (data['auctionId'] as String?)?.trim(),
      category: (data['category'] as String?)?.trim(),
      actorUid: (data['actorUid'] as String?)?.trim(),
    );
  }
}
