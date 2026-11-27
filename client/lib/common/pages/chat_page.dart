import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/chats_provider.dart';
import 'package:qfqq/common/utils/platform.dart';
import 'package:qfqq/common/widgets/chat_page/chat_list.dart';
import 'package:qfqq/common/widgets/chat_page/chat_message_input.dart';
import 'package:qfqq/common/widgets/chat_page/chat_messages.dart';
import 'package:qfqq/common/widgets/chat_page/create_chat_form.dart';
import 'package:qfqq/generated/l10n.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final chats = ref.watch(chatsProvider);

    final selectedChat = ref.watch(selectedChatProvider);
    final showCreation = selectedChat == null || ref.watch(chatUiProvider).showCreation;

    final headerTitle = selectedChat == null ? loc.chatCreateNew : selectedChat.name;

    final chatContent = Column(
      children: [
        _buildHeader(context, headerTitle, loc),
        const Divider(height: 1),
        if (isMobile) ...[
          MobileChatSelector(chats: chats),
          const Divider(height: 1),
        ],
        Expanded(
          child:
              showCreation
                  ? CreateChatForm()
                  : Column(
                    children: [
                      Expanded(child: ChatMessages(chatId: selectedChat.id)),
                      ChatMessageInput(),
                    ],
                  ),
        ),
      ],
    );

    if (isMobile) return chatContent;

    return Row(
      children: [
        SizedBox(
          width: 240,
          child: ChatSidebar(chats: chats),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: chatContent),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String chatName, S loc) {
    final showCreation = ref.read(chatUiProvider).showCreation;

    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                chatName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: loc.chatCreateNew,
              onPressed: showCreation
                      ? null
                      : () {
                        FocusScope.of(context).unfocus();
                        ref.read(chatUiProvider.notifier).setShowCreation(true);
                      },
              icon: const Icon(Icons.add_comment_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
