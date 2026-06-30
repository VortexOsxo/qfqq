import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/states/auth_state.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';
import 'package:qfqq/common/utils/platform.dart';

final pushNotificationServiceProvider = Provider((ref) {
  return PushNotificationService(
    ref.read(qfqqHttpClientProvider),
    ref.read(authStateProvider.notifier),
  );
});

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final QfqqHttpClient _http;

  PushNotificationService(this._http, AuthService authService) {
    authService.connectionNotifier.subscribe(_onconnection);
  }

  Future<void> requestPermissions(int userId) async {
    if (platformType != PlatformType.mobile) {
      return;
    }

    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    final String? token = await _messaging.getToken();

    print("🔥 FCM TOKEN: $token");

    if (token != null) {
      await _registerToken(userId, token);
    }

    _messaging.onTokenRefresh.listen((newToken) async {
      print("🔄 FCM TOKEN REFRESHED: $newToken");
      await _registerToken(userId, newToken);
    });
  }

  Future<void> _registerToken(int userId, String token) async {
    final _ = await _http.post(
      _http.getUri('users/$userId/fcm'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'fcm': token}),
    );
  }

  void _onconnection(AuthState auth) {
    final id = auth.user?.id;
    if (id != null) {
      requestPermissions(id);
    }
  }
}
