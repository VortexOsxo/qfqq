import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';


var pdfServiceProvider = Provider<PdfService>((ref) => PdfService(ref.read(qfqqHttpClientProvider)));

class PdfService {
  final QfqqHttpClient _client;

  PdfService(this._client);

  // TODO: Use proper url and download at the proper place
  Future<void> downloadPdfToDownloads(String url) async {
    final response = await _client.get(_client.getUri(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to download PDF');
    }

    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir == null) {
      throw Exception('Downloads directory not available');
    }

    final file = File('${downloadsDir.path}/report.pdf');
    await file.writeAsBytes(response.bodyBytes);
  }
}
