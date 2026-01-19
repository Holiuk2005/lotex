import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../data/notifications_repository.dart';
import '../../domain/app_notification.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(FirebaseFirestore.instance);
});

final notificationsStreamProvider = StreamProvider<List<AppNotification>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream<List<AppNotification>>.empty();
  return ref.watch(notificationsRepositoryProvider).watchLatest(user.uid);
});

final unreadNotificationsCountProvider = StreamProvider<int>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream<int>.empty();
  return ref.watch(notificationsRepositoryProvider).watchUnreadCount(user.uid);
});

final subscribedCategoriesProvider = StreamProvider<Set<String>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream<Set<String>>.empty();

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final raw = data['subscribedCategories'];
    if (raw is List) {
      return raw
          .whereType<String>()
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toSet();
    }
    return <String>{};
  });
});
