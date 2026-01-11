import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotex/core/utils/human_error.dart';
import 'package:lotex/core/theme/lotex_ui_tokens.dart';
import 'package:lotex/core/widgets/lotex_app_bar.dart';
import 'package:lotex/core/widgets/lotex_background.dart';
import '../providers/chat_providers.dart';
import 'package:lotex/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:lotex/core/i18n/language_provider.dart';
import 'package:lotex/core/i18n/lotex_i18n.dart';

class ChatConversationScreen extends ConsumerWidget {
  final String dialogId;
  final String role;
  final String title;

  const ChatConversationScreen({super.key, required this.dialogId, required this.role, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ConversationView(dialogId: dialogId, role: role, title: title);
  }
}

class ConversationView extends ConsumerWidget {
  final String dialogId;
  final String role;
  final String title;
  final bool embedded;

  const ConversationView({
    super.key,
    required this.dialogId,
    required this.role,
    required this.title,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(lotexLanguageProvider);
    final authUser = ref.watch(authStateChangesProvider).maybeWhen(data: (u) => u, orElse: () => null);
    final myUid = authUser?.uid;
    final msgs = ref.watch(conversationMessagesProvider({'dialogId': dialogId, 'role': role}));

    final content = Column(
      children: [
        if (embedded)
          _ConversationHeader(title: title)
        else
          const SizedBox.shrink(),
        Expanded(
          child: msgs.when(
            data: (list) {
              if (list.isEmpty) {
                return Center(
                  child: Text(
                    LotexI18n.tr(lang, 'noMessagesYet'),
                    style: const TextStyle(color: LotexUiColors.slate400, fontWeight: FontWeight.w600),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                reverse: true,
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final m = list[index];
                  final isMe = myUid != null && m.senderId == myUid;
                  return _MessageBubble(
                    text: m.text,
                    time: _formatTime(m.createdAt),
                    isMe: isMe,
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: LotexUiColors.violet500)),
            error: (e, s) => Center(
              child: Text(
                LotexI18n.tr(lang, 'errorWithDetails').replaceFirst('{details}', humanError(e)),
                style: const TextStyle(color: LotexUiColors.slate400),
              ),
            ),
          ),
        ),
        _ConversationInput(
          dialogId: dialogId,
          role: role,
          senderId: myUid ?? 'guest',
          lang: lang,
        ),
      ],
    );

    if (embedded) {
      return content;
    }

    return Scaffold(
      appBar: LotexAppBar(
        showBack: true,
        showDefaultActions: false,
        showDesktopSearch: false,
        titleText: title,
      ),
      body: Stack(
        children: [
          const LotexBackground(),
          content,
        ],
      ),
    );
  }
}

class _ConversationHeader extends StatelessWidget {
  final String title;
  const _ConversationHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.04 * 255).round()),
        border: Border(
          bottom: BorderSide(color: Colors.white.withAlpha((0.08 * 255).round())),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withAlpha((0.06 * 255).round()),
            child: Text(
              title.trim().isNotEmpty ? title.trim()[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call, color: LotexUiColors.slate400),
            tooltip: 'Call',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.videocam, color: LotexUiColors.slate400),
            tooltip: 'Video',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: LotexUiColors.slate400),
            tooltip: 'More',
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;

  const _MessageBubble({required this.text, required this.time, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final bg = isMe
        ? const BoxDecoration(
            gradient: LotexUiGradients.primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(6),
            ),
          )
        : BoxDecoration(
            color: Colors.white.withAlpha((0.08 * 255).round()),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
              bottomLeft: Radius.circular(6),
            ),
            border: Border.all(color: Colors.white.withAlpha((0.08 * 255).round())),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
          child: DecoratedBox(
            decoration: bg,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : LotexUiColors.darkBody,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      time,
                      style: TextStyle(
                        color: (isMe ? Colors.white : LotexUiColors.slate500).withAlpha((0.75 * 255).round()),
                        fontSize: 10,
                        height: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationInput extends ConsumerStatefulWidget {
  final String dialogId;
  final String role;
  final String senderId;
  final LotexLanguage lang;
  const _ConversationInput({required this.dialogId, required this.role, required this.senderId, required this.lang});

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

    if (widget.senderId.trim().isEmpty || widget.senderId == 'guest') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LotexI18n.tr(widget.lang, 'authRequired'))),
      );
      return;
    }

    final repo = ref.read(chatRepositoryProvider);
    try {
      await repo.sendMessage(
        text: text,
        senderId: widget.senderId,
        role: widget.role,
        dialogId: widget.dialogId,
      );
      if (mounted) _controller.clear();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Помилка: ${humanError(e)}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.06 * 255).round()),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withAlpha((0.10 * 255).round())),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _controller,
                  maxLines: 1,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: LotexI18n.tr(widget.lang, 'typeMessage'),
                    hintStyle: const TextStyle(color: LotexUiColors.slate500, fontWeight: FontWeight.w600),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 48,
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LotexUiGradients.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: LotexUiShadows.glow,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _send,
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatTime(DateTime dt) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(dt.hour)}:${two(dt.minute)}';
}
