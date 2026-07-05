import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/states/auth_state.dart';
import 'package:qfqq/common/providers/locale_provider.dart';
import 'package:qfqq/common/providers/router_provider.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';

final pushNotificationServiceProvider = Provider((ref) {
  return PushNotificationService(
    ref.read(qfqqHttpClientProvider),
    ref.read(authStateProvider.notifier),
    ref.read(localeProvider.notifier),
    ref.read(routerProvider),
  );
});

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final QfqqHttpClient _http;
  final LocaleNotifier _locale;
  final GoRouter _router;

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  PushNotificationService(this._http, AuthService authService, this._locale, this._router) {
    authService.connectionNotifier.subscribe(_initialize);
    authService.disconnectionNotifier.subscribe(_clear);
  }

  Future<void> _initialize(AuthState auth) async {
    final id = auth.user?.id;
    assert(id != null);

    _clear(null);
    await _requestPermissions(id!);

    _foregroundSubscription = FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    _openedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

    _checkInitialMessage();
  }

  void _clear(_) {
    _foregroundSubscription?.cancel();
    _openedAppSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();
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
    final data = message.data;
    final type = data['type'];
    final id = data['id'];

    if (id == null) return;

    if (type == 'MeetingStart') {
      _router.go('/agendas/$id');
    } else if (type == 'DecisionDue') {
      _router.go('/decisions/$id');
    }
  }

  Future<void> _requestPermissions(int userId) async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    final String? token = await _messaging.getToken();

    if (token != null) {
      await _registerToken(userId, token);
    }

    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((newToken) async {
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
