import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:qfqq/common/providers/locale_provider.dart';
import 'package:qfqq/common/services/auth_service.dart';

var qfqqHttpClientProvider = Provider(
  (ref) => QfqqHttpClient(
    ref.read(authStateProvider.notifier),
    ref.read(localeProvider.notifier),
  ),
);

const _version = String.fromEnvironment("VERSION");
const _apiUrl = String.fromEnvironment("API_URL");

class QfqqHttpClient extends http.BaseClient {
  final LocaleNotifier _locale;
  final http.Client _inner = http.Client();

  String? token;

  QfqqHttpClient(AuthService authService, this._locale)
    : token = authService.getSessionId() {
    _initSubscription(authService);
  }

  //TODO: Can we move this inside of the send method, so it does it automatically ?
  Uri getUri(String route) {
    return Uri.parse('$_apiUrl/$route');
  }

  void addHeaders(Map<String, String> headers) {
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    headers['QfqqVersion'] = _version;
    headers['Accept-Language'] = _locale.getLocaleCode();
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    addHeaders(request.headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }

  void _initSubscription(AuthService authService) {
    authService.connectionNotifier.subscribe(
      (_) => token = authService.getSessionId(),
    );
    authService.disconnectionNotifier.subscribe((_) => token = null);
  }
}
