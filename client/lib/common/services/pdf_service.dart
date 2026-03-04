import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';

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

    final result = await FilePicker.platform.saveFile(
      fileName: _formatPdfName(name),
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) {
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
