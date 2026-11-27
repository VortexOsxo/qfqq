import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/chat.dart';
import 'package:qfqq/common/models/chat_message.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/chat_service.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';

final chatsProvider = StateNotifierProvider<ChatService, List<Chat>>(
  (ref) => ChatService(
    ref.read(qfqqHttpClientProvider),
    ref.read(authStateProvider.notifier),
  ),
);

const chatMessagesPageSize = 25;

final chatMessagesLimitProvider = StateProvider.autoDispose.family<int, int>(
  (ref, chatId) => chatMessagesPageSize,
);

final chatMessagesProvider =
    FutureProvider.autoDispose.family<List<ChatMessage>, int>((ref, chatId) {
      final limit = ref.watch(chatMessagesLimitProvider(chatId));
      return ref.read(chatsProvider.notifier).getMessages(chatId, limit: limit);
    });

final chatUiProvider = StateNotifierProvider<ChatUiService, ChatUiState>((ref) => ChatUiService());

final selectedChatProvider = Provider<Chat?>((ref) {
  final chats = ref.watch(chatsProvider);
  final uiState = ref.watch(chatUiProvider);

  if (uiState.showCreation) {
    return null;
  }

  for (final chat in chats) {
    if (chat.id == uiState.chatId) return chat;
  }

  return null;
});
