import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotex/core/theme/app_text_styles.dart';
import 'package:lotex/core/widgets/app_input.dart';
import '../providers/chat_providers.dart';

class ChatConversationScreen extends ConsumerWidget {
  final String dialogId;
  final String role;
  final String title;

  const ChatConversationScreen({super.key, required this.dialogId, required this.role, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final msgs = ref.watch(conversationMessagesProvider({'dialogId': dialogId, 'role': role}));
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Expanded(
            child: msgs.when(
              data: (list) {
                if (list.isEmpty) return Center(child: Text('Немає повідомлень', style: AppTextStyles.bodyRegular));
                return ListView.builder(
                  reverse: true,
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final m = list[index];
                    return ListTile(title: Text(m.text), subtitle: Text(m.senderId));
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Помилка: $e')),
            ),
          ),
          _ConversationInput(dialogId: dialogId, role: role),
        ],
      ),
    );
  }
}

class _ConversationInput extends ConsumerStatefulWidget {
  final String dialogId;
  final String role;
  const _ConversationInput({required this.dialogId, required this.role});

  @override
  ConsumerState<_ConversationInput> createState() => _ConversationInputState();
}

class _ConversationInputState extends ConsumerState<_ConversationInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final repo = ref.read(chatRepositoryProvider);
    // get current user id if available
    try {
      await repo.sendMessage(text: text, senderId: 'user', role: widget.role, dialogId: widget.dialogId);
      if (mounted) _controller.clear();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Помилка: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: AppInput(label: 'Напишіть повідомлення...', controller: _controller, maxLines: 1),
            ),
            IconButton(onPressed: _send, icon: const Icon(Icons.send)),
          ],
        ),
      ),
    );
  }
}
