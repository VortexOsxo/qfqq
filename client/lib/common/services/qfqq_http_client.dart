import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:qfqq/common/providers/locale_provider.dart';
import 'package:qfqq/common/services/modal_service.dart';
import 'package:qfqq/common/services/session_token_store.dart';
import 'package:qfqq/generated/l10n.dart';

var qfqqHttpClientProvider = Provider(
  (ref) => QfqqHttpClient(
    ref.read(sessionTokenStoreProvider),
    ref.read(localeProvider.notifier),
  ),
);

const _version = String.fromEnvironment("VERSION");
const _apiUrl = String.fromEnvironment("API_URL");

class QfqqHttpClient extends http.BaseClient {
  final LocaleNotifier _locale;
  final http.Client _inner = http.Client();
  final SessionTokenStore _sessionTokenStore;

  QfqqHttpClient(this._sessionTokenStore, this._locale);

  //TODO: Can we move this inside of the send method, so it does it automatically ?
  Uri getUri(String route) {
    return Uri.parse('$_apiUrl/$route');
  }

  void addHeaders(Map<String, String> headers) {
    final token = _sessionTokenStore.token;
     if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    headers['QfqqVersion'] = _version;
    headers['Accept-Language'] = _locale.getLocaleCode();
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    addHeaders(request.headers);
    try {
      final response = await _inner.send(request);
      if (response.statusCode == 403) {
        ModalService.showInformation(
          title: S.current.commonPermissionErrorTitle,
          message: S.current.commonPermissionErrorMessage,
        );
      }
      return response;
    } on http.ClientException catch (error, stackTrace) {
      ModalService.showInformation(
        title: S.current.commonConnectionError,
        message: S.current.commonNetworkConnectionError,
      );
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
