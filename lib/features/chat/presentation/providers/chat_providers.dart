import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/chat_repository.dart';
import '../../domain/entities/chat_message.dart';
final chatRepositoryProvider = Provider((ref) => ChatRepository(firestore: FirebaseFirestore.instance));

final sellerMessagesProvider = StreamProvider.autoDispose<List<ChatMessage>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.messagesStream(role: 'seller');
});

final buyerMessagesProvider = StreamProvider.autoDispose<List<ChatMessage>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.messagesStream(role: 'buyer');
});

final sellerDialogsProvider = StreamProvider.autoDispose((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.dialogsStream(role: 'seller');
});

final buyerDialogsProvider = StreamProvider.autoDispose((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.dialogsStream(role: 'buyer');
});

final conversationMessagesProvider = StreamProvider.autoDispose.family<List<ChatMessage>, Map<String, String?>>((ref, params) {
  final repo = ref.watch(chatRepositoryProvider);
  final role = params['role'] ?? 'buyer';
  final dialogId = params['dialogId'];
  return repo.messagesStream(dialogId: dialogId, role: role);
});

final chatSendProvider = Provider((ref) => ref.read(chatRepositoryProvider));
