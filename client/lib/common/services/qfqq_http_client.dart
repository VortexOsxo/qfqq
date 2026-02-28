import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:qfqq/common/services/auth_service.dart';

var qfqqHttpClientProvider = Provider(
  (ref) => QfqqHttpClient(ref.read(authStateProvider.notifier)),
);

const _version = String.fromEnvironment("VERSION");

class QfqqHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  static const String _apiUrl = String.fromEnvironment("API_URL");

  String? token;

  QfqqHttpClient(AuthService authService) : token = authService.getSessionId() {
    _initSubscription(authService);
  }

  Uri getUri(String route) {
    return Uri.parse('$_apiUrl/$route');
  }

  void addHeaders(Map<String,String> headers) {
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    headers['QfqqVersion'] = _version;
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
