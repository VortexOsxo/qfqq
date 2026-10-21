import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';
import 'package:qfqq/common/utils/platform.dart';

var pdfServiceProvider = Provider<PdfService>(
  (ref) => PdfService(ref.read(qfqqHttpClientProvider)),
);

class PdfService {
  final QfqqHttpClient _client;

  PdfService(this._client);

  Future<void> downloadPdfToDownloads(String url, String name) async {
    final response = await _client.get(_client.getUri(url));

    if (response.statusCode != 200) {
      return; // TODO: Show error message
    }

    final isMobile = platformType == PlatformType.mobile;

    final result = await FilePicker.platform.saveFile(
      fileName: _formatPdfName(name),
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      bytes: isMobile ? response.bodyBytes : null,
    );

    if (result == null || isMobile) {
      return;
    }

    final file = File(result);
    await file.writeAsBytes(response.bodyBytes);
  }

  String _formatPdfName(String name) {
    name = name.replaceAll(RegExp(r' '), '-');
    return '$name.pdf';
  }
}
