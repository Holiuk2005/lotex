import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/chat_message.dart';
import '../domain/entities/chat_dialog.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  // Stream dialogs for a user, filtered by role.
  // Important: we intentionally avoid composite-index queries (no orderBy/extra where)
  // and sort/filter on the client.
  Stream<List<ChatDialog>> dialogsStream({required String role, required String userId}) {
    return _firestore
        .collection('dialogs')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) => ChatDialog.fromDoc(d)).where((d) => d.role == role).toList();
          list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return list;
        });
  }

  // Stream messages. Avoid composite-index queries; sort on the client.
  Stream<List<ChatMessage>> messagesStream({String? dialogId, required String role}) {
    final col = _firestore.collection('chats');

    // IMPORTANT: Role-only queries are not compatible with our security rules.
    // Reading chats requires being a participant of the dialog, so we must scope
    // reads by a конкретний dialogId.
    if (dialogId == null || dialogId.isEmpty) {
      return Stream.value(const <ChatMessage>[]);
    }

    final Query q = col.where('dialogId', isEqualTo: dialogId);

    return q.snapshots().map((snap) {
      final list = snap.docs.map((d) => ChatMessage.fromDoc(d)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> sendMessage({required String text, required String senderId, required String role, String? dialogId}) async {
    final msg = ChatMessage(id: '', text: text, senderId: senderId, role: role, createdAt: DateTime.now());
    final data = msg.toMap();
    if (dialogId != null) data['dialogId'] = dialogId;
    await _firestore.collection('chats').add(data);
    // update dialog updatedAt
    if (dialogId != null && dialogId.isNotEmpty) {
      await _firestore.collection('dialogs').doc(dialogId).update({
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'lastMessage': text,
        'lastSenderId': senderId,
      });

      // Mirror message to the peer dialog (so both buyer/seller tabs see the conversation).
      try {
        final dialogDoc = await _firestore.collection('dialogs').doc(dialogId).get();
        final peerDialogId = (dialogDoc.data()?['peerDialogId'] as String?) ?? '';
        if (peerDialogId.isNotEmpty) {
          final peerRole = role == 'buyer' ? 'seller' : 'buyer';
          final peerMsg = ChatMessage(id: '', text: text, senderId: senderId, role: peerRole, createdAt: DateTime.now());
          final peerData = peerMsg.toMap();
          peerData['dialogId'] = peerDialogId;
          await _firestore.collection('chats').add(peerData);
          await _firestore.collection('dialogs').doc(peerDialogId).set({
            'updatedAt': Timestamp.fromDate(DateTime.now()),
            'lastMessage': text,
            'lastSenderId': senderId,
          }, SetOptions(merge: true));
        }
      } catch (_) {
        // Ignore peer-mirroring errors; primary send already succeeded.
      }
    }
  }

  // Create dialog
  Future<String> createDialog({required String title, required String role, required List<String> participants}) async {
    final doc = await _firestore.collection('dialogs').add({
      'title': title,
      'role': role,
      'participants': participants,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
      'lastMessage': '',
      'lastSenderId': '',
    });
    return doc.id;
  }

  static String _auctionDialogId({
    required String auctionId,
    required String buyerId,
    required String sellerId,
    required String role,
  }) {
    // Deterministic IDs so we can create/open dialogs without querying.
    return 'a_${auctionId}_b_${buyerId}_s_${sellerId}_r_$role';
  }

  Future<String> ensureAuctionDialog({
    required String auctionId,
    required String buyerId,
    required String sellerId,
    required String title,
  }) async {
    final buyerDialogId = _auctionDialogId(
      auctionId: auctionId,
      buyerId: buyerId,
      sellerId: sellerId,
      role: 'buyer',
    );
    final sellerDialogId = _auctionDialogId(
      auctionId: auctionId,
      buyerId: buyerId,
      sellerId: sellerId,
      role: 'seller',
    );

    final now = Timestamp.fromDate(DateTime.now());
    final participants = <String>[buyerId, sellerId];

    await _firestore.collection('dialogs').doc(buyerDialogId).set({
      'title': title,
      'role': 'buyer',
      'participants': participants,
      'auctionId': auctionId,
      'peerDialogId': sellerDialogId,
      'updatedAt': now,
      'lastMessage': '',
      'lastSenderId': '',
    }, SetOptions(merge: true));

    await _firestore.collection('dialogs').doc(sellerDialogId).set({
      'title': title,
      'role': 'seller',
      'participants': participants,
      'auctionId': auctionId,
      'peerDialogId': buyerDialogId,
      'updatedAt': now,
      'lastMessage': '',
      'lastSenderId': '',
    }, SetOptions(merge: true));

    return buyerDialogId;
  }
}
