import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lotex/core/theme/lotex_ui_tokens.dart';
import 'package:lotex/core/utils/human_error.dart';
import 'package:lotex/core/widgets/lotex_app_bar.dart';

class BidHistoryScreen extends StatelessWidget {
  const BidHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final muted = Theme.of(context).brightness == Brightness.dark
        ? LotexUiColors.darkMuted
        : LotexUiColors.lightMuted;

    return Scaffold(
      appBar: const LotexAppBar(
        showBack: true,
        showDesktopSearch: false,
        titleText: 'Історія ставок',
      ),
      body: uid == null
          ? Center(child: Text('Увійдіть в акаунт', style: LotexUiTextStyles.bodyRegular))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('bids')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Помилка: ${humanError(snapshot.error ?? Exception('Unknown error'))}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: LotexUiColors.violet600));
                }

                final sorted = snapshot.data!.docs.toList(growable: false);
                sorted.sort((a, b) {
                  DateTime at = DateTime.fromMillisecondsSinceEpoch(0);
                  DateTime bt = DateTime.fromMillisecondsSinceEpoch(0);

                  final aRaw = a.data()['timestamp'];
                  final bRaw = b.data()['timestamp'];
                  if (aRaw is Timestamp) at = aRaw.toDate();
                  if (bRaw is Timestamp) bt = bRaw.toDate();
                  return bt.compareTo(at);
                });

                final docs = sorted.take(100).toList(growable: false);
                if (docs.isEmpty) {
                  return Center(child: Text('У вас ще немає ставок', style: LotexUiTextStyles.bodyRegular));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
                    final userName = (data['userName'] as String?) ?? '';
                    final ts = data['timestamp'];
                    final time = ts is Timestamp ? ts.toDate() : null;

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: LotexUiColors.violet500.withAlpha((0.15 * 255).round()),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.history_rounded, color: LotexUiColors.violet600),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${amount.toStringAsFixed(0)} ₴',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  time != null ? time.toString() : '—',
                                  style: LotexUiTextStyles.bodyRegular.copyWith(color: muted),
                                ),
                              ],
                            ),
                          ),
                          if (userName.isNotEmpty)
                            Text(
                              userName,
                              style: LotexUiTextStyles.bodyRegular.copyWith(color: muted),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
