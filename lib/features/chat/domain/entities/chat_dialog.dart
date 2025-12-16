import 'package:cloud_firestore/cloud_firestore.dart';

class ChatDialog {
  final String id;
  final String title; // e.g., lot title or participant names
  final String role; // 'seller' or 'buyer'
  final DateTime updatedAt;
  final List<String> participants;

  ChatDialog({required this.id, required this.title, required this.role, required this.updatedAt, required this.participants});

  Map<String, dynamic> toMap() => {
        'title': title,
        'role': role,
        'updatedAt': Timestamp.fromDate(updatedAt),
        'participants': participants,
      };

  factory ChatDialog.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatDialog(
      id: doc.id,
      title: data['title'] ?? '',
      role: data['role'] ?? 'buyer',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      participants: List<String>.from(data['participants'] ?? []),
    );
  }
}
