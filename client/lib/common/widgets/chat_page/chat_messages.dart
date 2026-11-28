import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/chats_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/generated/l10n.dart';

class ChatMessages extends ConsumerWidget {
  final int chatId;

  const ChatMessages({super.key, required this.chatId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);
    final users = ref.watch(usersProvider);
    final currentUserId = ref.watch(
      authStateProvider.select((state) => state.user?.id),
    );
    final colorScheme = Theme.of(context).colorScheme;
    final limit = ref.watch(chatMessagesLimitProvider(chatId));
    final messages = ref.watch(chatMessagesProvider(chatId));

    return messages.when(
      skipLoadingOnRefresh: false,
      skipLoadingOnReload: false,
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stackTrace) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(loc.chatMessagesLoadFailure),
                TextButton(
                  onPressed: () => ref.invalidate(chatMessagesProvider(chatId)),
                  child: Text(loc.commonRetry),
                ),
              ],
            ),
          ),
      data: (messages) {
        if (messages.isEmpty) return Center(child: Text(loc.chatMessagesEmpty));

        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length + (messages.length == limit ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == messages.length) {
              return TextButton(
                onPressed:
                    () =>
                        ref
                            .read(chatMessagesLimitProvider(chatId).notifier)
                            .state += chatMessagesPageSize,
                child: Text(loc.chatMessagesLoadOlder),
              );
            }
            final message = messages[index];
            final isOwnMessage = message.senderId == currentUserId;
            final sender = users.firstWhereOrNull(
              (user) => user.id == message.senderId,
            );
            final senderName = sender?.displayName;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment:
                    isOwnMessage
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                children: [
                  Text(
                    '$senderName · ${formatDate(context, message.sentAt.toLocal())}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isOwnMessage
                              ? colorScheme.primaryContainer
                              : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color:
                            isOwnMessage
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
