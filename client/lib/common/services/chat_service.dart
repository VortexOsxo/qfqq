import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/chat.dart';
import 'package:qfqq/common/models/chat_message.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';
import 'package:qfqq/common/services/web_socket_service.dart';

class ChatService extends StateNotifier<List<Chat>> {
  final QfqqHttpClient _http;
  final void Function(int chatId) _invalidateChatMessages;

  ChatService(
    this._http,
    AuthService auth, {
    required void Function(int chatId) invalidateChatMessages,
  }) : _invalidateChatMessages = invalidateChatMessages,
       super([]) {
    WebSocketService.registerHandler('chat', chatEventHandler);
    auth.connectionNotifier.subscribe((_) => loadChats());
    auth.disconnectionNotifier.subscribe((_) => _clearChats());

    if (auth.isAuthenticated()) loadChats();
  }

  @override
  void dispose() {
    WebSocketService.unregisterHandler('chat');
    super.dispose();
  }

  void _clearChats() => state = [];

  Future<({int statusCode, int? chatId})> createChat(
    String name,
    List<int> participantIds,
  ) async {
    final response = await _http.post(
      _http.getUri('chats'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'chatName': name, 'userIds': participantIds}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final chat = Chat.fromJson(data);
      final index = state.indexWhere((existing) => existing.id == chat.id);
      if (index == -1) {
        state = [...state, chat];
      } else {
        state = [...state]..[index] = chat;
      }
      return (statusCode: response.statusCode, chatId: chat.id);
    }

    return (statusCode: response.statusCode, chatId: null);
  }

  Future<int> sendMessage(int chatId, String content) async {
    final response = await _http.post(
      _http.getUri('chats/$chatId/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'content': content}),
    );
    if (response.statusCode == 201) {
      WebSocketService.send('chat', 'sendMessage', {'chatId': chatId});
    }
    return response.statusCode;
  }

  Future<List<ChatMessage>> getMessages(int chatId, {int limit = 50}) async {
    final uri = _http
        .getUri('chats/$chatId/messages')
        .replace(queryParameters: {'limit': '$limit'});

    final response = await _http.get(uri);
    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => ChatMessage.fromJson(item)).toList();
  }

  Future<void> loadChats() async {
    final response = await _http.get(
      _http.getUri('chats'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      return;
    }

    final List<dynamic> data = jsonDecode(response.body);
    state =
        data
            .map((item) => Chat.fromJson(item as Map<String, dynamic>))
            .toList();
  }

  void chatEventHandler(dynamic event) {
    print('Client event: $event');

    if (event["type"] == "receiveMessage") {
      final chatId = event["chatId"] as int;
      _invalidateChatMessages(chatId);
    }
  }
}

class ChatUiState {
  final int? chatId;
  final bool showCreation;

  const ChatUiState(this.chatId, this.showCreation);

  ChatUiState copyWith({int? chatId, bool? showCreation}) =>
      ChatUiState(chatId ?? this.chatId, showCreation ?? this.showCreation);
}

class ChatUiService extends StateNotifier<ChatUiState> {
  ChatUiService() : super(ChatUiState(null, false));

  void selectChat(int chatId) =>
      state = state.copyWith(chatId: chatId, showCreation: false);
  void setShowCreation(bool showCreation) =>
      state = state.copyWith(showCreation: showCreation);
}
