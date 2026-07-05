import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

const _websocketUrl = String.fromEnvironment("WEBSOCKET_URL");

class WebSocketService {
  static WebSocketChannel? channel;
  static Map<String, Function> handlers = {};

  static void connect() {
    if (channel != null) {
      return;
    }

    channel = WebSocketChannel.connect(Uri.parse(_websocketUrl));
    channel!.stream.listen(_onEvent); // Handle error and disconnect ?
  }

  static void registerHandler(String name, Function handler) {
    handlers.update(name, (_) => handler, ifAbsent: () => handler);
  }

  static void unregisterHandler(String name) {
    handlers.remove(name);
  }

  static void send(String handler, String type, Map<String, dynamic> data) {
    final event = jsonEncode({'handler': handler, 'type': type, ...data});
    channel?.sink.add(event);
  }

  static void disconnect() {
    channel?.sink.close();
  }

  static void _onEvent(dynamic message) {
    final dynamic event;
    try {
      event = jsonDecode(message as String);
    } catch (_) {
      return;
    }

    final handlerKey = event['handler'];

    if (handlerKey == null || !handlers.containsKey(handlerKey)) {
      return;
    }

    final handler = handlers[handlerKey];
    handler?.call(event);
  }
}
