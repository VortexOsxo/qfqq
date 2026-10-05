import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';

final notificationSettingsServiceProvider =
    Provider<NotificationSettingsService>(
      (ref) => NotificationSettingsService(ref.read(qfqqHttpClientProvider)),
    );

enum NotificationType {
  meetingStart('MeetingStart'),
  meetingStarted('MeetingStarted'),
  decisionDue('DecisionDue');

  const NotificationType(this.value);

  final String value;

  static NotificationType fromValue(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw FormatException('Unknown notification type: $value'),
    );
  }
}

class NotificationOffset {
  const NotificationOffset({required this.type, required this.offset});

  final NotificationType type;
  final Duration offset;

  factory NotificationOffset.fromJson(Map<String, dynamic> json) {
    final seconds = json['offset'];
    if (seconds is! num) {
      throw const FormatException('Notification offset must be a number.');
    }

    return NotificationOffset(
      type: NotificationType.fromValue(json['type'] as String),
      offset: Duration(
        microseconds: (seconds * Duration.microsecondsPerSecond).round(),
      ),
    );
  }
}

class NotificationSettingsService {
  NotificationSettingsService(this._http);

  final QfqqHttpClient _http;

  static const _route = 'users/settings/notifications-offset';

  Future<bool> updateNotificationOffset(
    NotificationType type,
    Duration offset,
  ) async {
    final seconds = offset.inMicroseconds / Duration.microsecondsPerSecond;
    final response = await _http.post(
      _http.getUri(_route),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'type': type.value, 'offset': '$seconds seconds'}),
    );

    return response.statusCode == 204;
  }

  Future<NotificationOffset?> getNotificationOffset(
    NotificationType type,
  ) async {
    final response = await _http.get(
      _http.getUri('$_route/${Uri.encodeComponent(type.value)}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 404) return null;

    return NotificationOffset.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<List<NotificationOffset>> getNotificationOffsets() async {
    final response = await _http.get(
      _http.getUri(_route),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw StateError(
        'Failed to load notification offsets: HTTP ${response.statusCode}.',
      );
    }

    final offsets = jsonDecode(response.body) as List<dynamic>;
    return offsets
        .map(
          (item) => NotificationOffset.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
