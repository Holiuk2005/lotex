import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String text;
  final String senderId;
  final String role; // 'seller' or 'buyer'
  final DateTime createdAt;

  ChatMessage({required this.id, required this.text, required this.senderId, required this.role, required this.createdAt});

  Map<String, dynamic> toMap() => {
        'text': text,
        'senderId': senderId,
        'role': role,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory ChatMessage.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      role: data['role'] ?? 'buyer',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
