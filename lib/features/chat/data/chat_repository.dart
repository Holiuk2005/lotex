import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/chat_message.dart';
import '../domain/entities/chat_dialog.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  // Stream dialogs by role
  Stream<List<ChatDialog>> dialogsStream({required String role}) {
    return _firestore
        .collection('dialogs')
        .where('role', isEqualTo: role)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ChatDialog.fromDoc(d)).toList());
  }

  // Stream messages, optionally filtered by dialogId
  Stream<List<ChatMessage>> messagesStream({String? dialogId, required String role}) {
    final col = _firestore.collection('chats');
    Query q = col.where('role', isEqualTo: role);
    if (dialogId != null && dialogId.isNotEmpty) {
      q = q.where('dialogId', isEqualTo: dialogId);
    }
    q = q.orderBy('createdAt', descending: true);
    return q.snapshots().map((snap) => snap.docs.map((d) => ChatMessage.fromDoc(d)).toList());
  }

  Future<void> sendMessage({required String text, required String senderId, required String role, String? dialogId}) async {
    final msg = ChatMessage(id: '', text: text, senderId: senderId, role: role, createdAt: DateTime.now());
    final data = msg.toMap();
    if (dialogId != null) data['dialogId'] = dialogId;
    await _firestore.collection('chats').add(data);
    // update dialog updatedAt
    if (dialogId != null && dialogId.isNotEmpty) {
      await _firestore.collection('dialogs').doc(dialogId).update({'updatedAt': Timestamp.fromDate(DateTime.now())});
    }
  }

  // Create dialog
  Future<String> createDialog({required String title, required String role, required List<String> participants}) async {
    final doc = await _firestore.collection('dialogs').add({
      'title': title,
      'role': role,
      'participants': participants,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
    return doc.id;
  }
}
