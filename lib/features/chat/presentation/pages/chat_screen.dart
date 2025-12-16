import 'package:flutter/material.dart';
import 'package:lotex/core/theme/app_colors.dart';
import 'package:lotex/core/theme/app_text_styles.dart';
import 'package:lotex/core/widgets/theme_toggle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_providers.dart';
import 'chat_conversation_screen.dart';
import 'package:lotex/features/auth/presentation/providers/auth_state_provider.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Чат'),
          elevation: 0,
          actions: const [ThemeToggle()],
          bottom: TabBar(
            indicatorColor: AppColors.primary500,
            labelColor: AppColors.primary500,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Продавець'),
              Tab(text: 'Покупець'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SellerChatTab(),
            _BuyerChatTab(),
          ],
        ),
      ),
    );
  }
}

class _SellerChatTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final dialogs = ref.watch(sellerDialogsProvider);
                return dialogs.when(
                  data: (list) {
                    if (list.isEmpty) return Center(child: Text('Немає діалогів', style: AppTextStyles.bodyRegular));
                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final d = list[index];
                        return ListTile(
                          title: Text(d.title),
                          subtitle: Text('${d.participants.length} учасників'),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ChatConversationScreen(dialogId: d.id, role: d.role, title: d.title)),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Помилка: $e')),
                );
              },
            ),
          ),
          _ChatInputArea(role: 'Продавець'),
        ],
      ),
    );
  }
}

class _BuyerChatTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final dialogs = ref.watch(buyerDialogsProvider);
                return dialogs.when(
                  data: (list) {
                    if (list.isEmpty) return Center(child: Text('Немає діалогів', style: AppTextStyles.bodyRegular));
                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final d = list[index];
                        return ListTile(
                          title: Text(d.title),
                          subtitle: Text('${d.participants.length} учасників'),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ChatConversationScreen(dialogId: d.id, role: d.role, title: d.title)),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Помилка: $e')),
                );
              },
            ),
          ),
          _ChatInputArea(role: 'Покупець'),
        ],
      ),
    );
  }
}

class _ChatInputArea extends ConsumerStatefulWidget {
  final String role;
  const _ChatInputArea({required this.role});

  @override
  ConsumerState<_ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends ConsumerState<_ChatInputArea> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final chatRepo = ref.read(chatSendProvider);
    final authUser = ref.read(authStateChangesProvider).maybeWhen(data: (u) => u, orElse: () => null);
    final senderId = authUser?.uid ?? 'guest';
    await chatRepo.sendMessage(text: text, senderId: senderId, role: widget.role.toLowerCase());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Відправлено (${widget.role})')));
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Напишіть повідомлення...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            height: 48,
            child: ElevatedButton(
              onPressed: _send,
              style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(12)),
              child: const Icon(Icons.send),
            ),
          ),
        ],
      ),
    );
  }
}
