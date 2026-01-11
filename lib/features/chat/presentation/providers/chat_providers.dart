import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/chat_repository.dart';
import '../../domain/entities/chat_message.dart';
import 'package:lotex/features/auth/presentation/providers/auth_state_provider.dart';
import '../../domain/entities/chat_dialog.dart';
final chatRepositoryProvider = Provider((ref) => ChatRepository(firestore: FirebaseFirestore.instance));

final sellerMessagesProvider = StreamProvider.autoDispose<List<ChatMessage>>((ref) {
  // Deprecated: role-only message streams are not allowed by security rules.
  // Use conversationMessagesProvider(dialogId: ...) instead.
  return Stream.value(const <ChatMessage>[]);
});

final buyerMessagesProvider = StreamProvider.autoDispose<List<ChatMessage>>((ref) {
  // Deprecated: role-only message streams are not allowed by security rules.
  // Use conversationMessagesProvider(dialogId: ...) instead.
  return Stream.value(const <ChatMessage>[]);
});

final sellerDialogsProvider = StreamProvider.autoDispose<List<ChatDialog>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null || uid.isEmpty) return Stream.value(const <ChatDialog>[]);
  return repo.dialogsStream(role: 'seller', userId: uid);
});

final buyerDialogsProvider = StreamProvider.autoDispose<List<ChatDialog>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null || uid.isEmpty) return Stream.value(const <ChatDialog>[]);
  return repo.dialogsStream(role: 'buyer', userId: uid);
});

final conversationMessagesProvider = StreamProvider.autoDispose.family<List<ChatMessage>, Map<String, String?>>((ref, params) {
  final repo = ref.watch(chatRepositoryProvider);
  final role = params['role'] ?? 'buyer';
  final dialogId = params['dialogId'];
  return repo.messagesStream(dialogId: dialogId, role: role);
});

final chatSendProvider = Provider((ref) => ref.read(chatRepositoryProvider));
