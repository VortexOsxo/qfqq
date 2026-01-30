import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PdfService {
  Future<void> downloadPdfToDownloads(String url) async {
    final response = await http.get(Uri.parse(url));

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
