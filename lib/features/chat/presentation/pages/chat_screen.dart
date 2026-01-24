import 'package:flutter/material.dart';
import 'package:lotex/core/theme/lotex_ui_tokens.dart';
import 'package:lotex/core/widgets/lotex_app_bar.dart';
import 'package:lotex/core/widgets/lotex_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_providers.dart';
import 'chat_conversation_screen.dart';
import 'package:lotex/core/i18n/language_provider.dart';
import 'package:lotex/core/i18n/lotex_i18n.dart';
import 'package:lotex/core/utils/human_error.dart';
import 'package:lotex/core/widgets/empty_state_widget.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _search = TextEditingController();
  String? _selectedDialogId;
  String? _selectedRole;
  String? _selectedTitle;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(lotexLanguageProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: LotexAppBar(
          titleText: LotexI18n.tr(lang, 'messages'),
          showDefaultActions: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.05 * 255).round()),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withAlpha((0.10 * 255).round())),
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: Colors.white.withAlpha((0.10 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: LotexUiColors.slate400,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  tabs: [
                    Tab(text: LotexI18n.tr(lang, 'seller')),
                    Tab(text: LotexI18n.tr(lang, 'buyer')),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            const LotexBackground(),
            TabBarView(
              children: [
                _DialogsTab(
                  role: 'seller',
                  lang: lang,
                  isWide: isWide,
                  searchText: _search.text,
                  onSearchChanged: (v) => setState(() {}),
                  onSelectDialog: (id, role, title) {
                    if (isWide) {
                      setState(() {
                        _selectedDialogId = id;
                        _selectedRole = role;
                        _selectedTitle = title;
                      });
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatConversationScreen(dialogId: id, role: role, title: title),
                      ),
                    );
                  },
                  selectedDialogId: _selectedDialogId,
                  rightPane: isWide
                      ? (_selectedDialogId == null || _selectedRole == null || _selectedTitle == null)
                          ? _EmptyConversation(lang: lang)
                          : ConversationView(
                              dialogId: _selectedDialogId!,
                              role: _selectedRole!,
                              title: _selectedTitle!,
                              embedded: true,
                            )
                      : null,
                  searchController: _search,
                ),
                _DialogsTab(
                  role: 'buyer',
                  lang: lang,
                  isWide: isWide,
                  searchText: _search.text,
                  onSearchChanged: (v) => setState(() {}),
                  onSelectDialog: (id, role, title) {
                    if (isWide) {
                      setState(() {
                        _selectedDialogId = id;
                        _selectedRole = role;
                        _selectedTitle = title;
                      });
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatConversationScreen(dialogId: id, role: role, title: title),
                      ),
                    );
                  },
                  selectedDialogId: _selectedDialogId,
                  rightPane: isWide
                      ? (_selectedDialogId == null || _selectedRole == null || _selectedTitle == null)
                          ? _EmptyConversation(lang: lang)
                          : ConversationView(
                              dialogId: _selectedDialogId!,
                              role: _selectedRole!,
                              title: _selectedTitle!,
                              embedded: true,
                            )
                      : null,
                  searchController: _search,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogsTab extends ConsumerWidget {
  final String role;
  final LotexLanguage lang;
  final bool isWide;
  final String searchText;
  final ValueChanged<String> onSearchChanged;
  final void Function(String id, String role, String title) onSelectDialog;
  final String? selectedDialogId;
  final Widget? rightPane;
  final TextEditingController searchController;

  const _DialogsTab({
    required this.role,
    required this.lang,
    required this.isWide,
    required this.searchText,
    required this.onSearchChanged,
    required this.onSelectDialog,
    required this.selectedDialogId,
    required this.rightPane,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dialogs = role == 'seller' ? ref.watch(sellerDialogsProvider) : ref.watch(buyerDialogsProvider);

    final listPane = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.04 * 255).round()),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withAlpha((0.08 * 255).round())),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.search, color: LotexUiColors.slate400, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      hintText: 'Search messages...',
                      hintStyle: TextStyle(color: LotexUiColors.slate500, fontWeight: FontWeight.w600),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (searchController.text.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      searchController.clear();
                      onSearchChanged('');
                    },
                    icon: const Icon(Icons.close, color: LotexUiColors.slate400, size: 18),
                    tooltip: 'Clear',
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.04 * 255).round()),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha((0.08 * 255).round())),
              ),
              child: dialogs.when(
                data: (list) {
                  final q = searchController.text.trim().toLowerCase();
                  final filtered = q.isEmpty
                      ? list
                      : list.where((d) => d.title.toLowerCase().contains(q)).toList();

                  if (filtered.isEmpty) {
                    return EmptyStateWidget(
                      title: q.isEmpty ? LotexI18n.tr(lang, 'noDialogs') : 'No messages yet',
                      icon: Icons.chat_bubble_outline,
                      buttonText: LotexI18n.tr(lang, 'startConversation'),
                      onButtonPressed: () {},
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => Divider(color: Colors.white.withAlpha((0.06 * 255).round())),
                    itemBuilder: (context, index) {
                      final d = filtered[index];
                      final isSelected = selectedDialogId != null && selectedDialogId == d.id;

                      return InkWell(
                        onTap: () => onSelectDialog(d.id, d.role, d.title),
                        child: Container(
                          color: isSelected ? Colors.white.withAlpha((0.06 * 255).round()) : Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.white.withAlpha((0.06 * 255).round()),
                                child: Text(
                                  (d.title.trim().isNotEmpty ? d.title.trim()[0].toUpperCase() : '?'),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            d.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _formatTime(d.updatedAt),
                                          style: const TextStyle(color: LotexUiColors.slate500, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      d.lastMessage.isNotEmpty
                                          ? d.lastMessage
                                          : '${d.participants.length} ${LotexI18n.tr(lang, 'participants')}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: LotexUiColors.slate400, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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
          ),
        ],
      ),
    );

    if (!isWide) return listPane;

    return Row(
      children: [
        SizedBox(width: 380, child: listPane),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 16, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.04 * 255).round()),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha((0.08 * 255).round())),
              ),
              child: rightPane,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyConversation extends StatelessWidget {
  final LotexLanguage lang;
  const _EmptyConversation({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        LotexI18n.tr(lang, 'noMessagesYet'),
        style: const TextStyle(color: LotexUiColors.slate400, fontWeight: FontWeight.w600),
      ),
    );
  }
}

String _formatTime(DateTime dt) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(dt.hour)}:${two(dt.minute)}';
}
