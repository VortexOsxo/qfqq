import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/chat.dart';
import 'package:qfqq/common/providers/chats_provider.dart';
import 'package:qfqq/generated/l10n.dart';

class ChatSidebar extends ConsumerWidget {
  final List<Chat> chats;

  const ChatSidebar({super.key, required this.chats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              loc.chatListTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
        Expanded(
          child:
              chats.isEmpty
                  ? Center(child: Text(loc.chatListEmpty))
                  : ListView.builder(
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          title: Text(
                            chat.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                          selected: chat.id == ref.watch(chatUiProvider).chatId,
                          onTap: () => ref.read(chatUiProvider.notifier).selectChat(chat.id),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}

class MobileChatSelector extends ConsumerWidget {
  final List<Chat> chats;

  const MobileChatSelector({super.key, required this.chats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);
    return SizedBox(
      height: 84,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Text(
              loc.chatListTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Expanded(
            child:
                chats.isEmpty
                    ? Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(loc.chatListEmpty),
                      ),
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      scrollDirection: Axis.horizontal,
                      itemCount: chats.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        return Center(
                          child: ChoiceChip(
                            label: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 180),
                              child: Text(
                                chat.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            selected: chat.id == ref.watch(chatUiProvider).chatId,
                            onSelected: (_) => ref.read(chatUiProvider.notifier).selectChat(chat.id),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
