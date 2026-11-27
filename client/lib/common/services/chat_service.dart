import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/chat.dart';
import 'package:qfqq/common/models/chat_message.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';

class ChatService extends StateNotifier<List<Chat>> {
  final QfqqHttpClient _http;

  ChatService(this._http, AuthService auth) : super([]) {
    auth.connectionNotifier.subscribe((_) => loadChats());
    auth.disconnectionNotifier.subscribe((_) => _clearChats());

    if (auth.isAuthenticated()) loadChats();
  }

  void _clearChats() => state = [];

  Future<int> createChat(String name, List<int> participantIds) async {
    final response = await _http.post(
      _http.getUri('chats'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'chatName': name, 'userIds': participantIds}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      state = [...state, Chat(id: data['id'] as int, name: name)];
    }

    return response.statusCode;
  }

  Future<int> sendMessage(int chatId, String content) async {
    final response = await _http.post(
      _http.getUri('chats/$chatId/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'content': content}),
    );
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

  void selectChat(int chatId) => state = state.copyWith(chatId: chatId, showCreation: false);
  void setShowCreation(bool showCreation) => state = state.copyWith(showCreation: showCreation);
}