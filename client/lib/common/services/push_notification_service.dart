import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/states/auth_state.dart';
import 'package:qfqq/common/providers/locale_provider.dart';
import 'package:qfqq/common/providers/router_provider.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';
import 'package:qfqq/common/utils/platform.dart';

final pushNotificationServiceProvider = Provider((ref) {
  return PushNotificationService(
    ref.read(qfqqHttpClientProvider),
    ref.read(routerProvider),
    ref.read(authStateProvider.notifier),
    ref.read(localeProvider.notifier),
  );
});

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final QfqqHttpClient _http;
  final GoRouter _router;
  final LocaleNotifier _locale;

  PushNotificationService(this._http, this._router, AuthService authService, this._locale) {
    authService.connectionNotifier.subscribe(_onconnection);
  }

  void initialize() {
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

    _checkInitialMessage();
  }

  void _onForegroundMessage(RemoteMessage message) {
    // TODO
  }

  Future<void> _checkInitialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();

    if (message != null) {
      _onMessageOpened(message);
    }
  }

  void _onMessageOpened(RemoteMessage message) {
    // TODO
  }

  void _onconnection(AuthState auth) {
    if (platformType != PlatformType.mobile) {
      return;
    }

    final id = auth.user?.id;
    if (id != null) {
      _requestPermissions(id);
    }

    initialize();
  }

  Future<void> _requestPermissions(int userId) async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    final String? token = await _messaging.getToken();

    if (token != null) {
      await _registerToken(userId, token);
    }

    _messaging.onTokenRefresh.listen((newToken) async {
      await _registerToken(userId, newToken);
    });
  }

  Future<void> _registerToken(int userId, String token) async {
    final _ = await _http.post(
      _http.getUri('users/$userId/fcm'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'fcm': token, 'locale': _locale.getLocaleCode()}),
    );
  }
}
