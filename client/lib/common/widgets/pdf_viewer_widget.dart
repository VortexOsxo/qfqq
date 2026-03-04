import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:qfqq/common/services/pdf_service.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';

class PdfViewerWidget extends ConsumerStatefulWidget {
  final String pdfUrl;

  const PdfViewerWidget({super.key, required this.pdfUrl});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _PdfViewerState();
  }
}

class _PdfViewerState extends ConsumerState<PdfViewerWidget> {
  final PdfViewerController _controller = PdfViewerController();

  @override
  Widget build(BuildContext context) {
    final downloadButton = IconButton(
      icon: const Icon(Icons.download),
      onPressed: () async {
        await ref.read(pdfServiceProvider).downloadPdfToDownloads(widget.pdfUrl);
      },
    );

    final zoomInButton = IconButton(
      icon: const Icon(Icons.zoom_in),
      onPressed: () {
        try {
          _controller.zoomUp();
        } catch (e) {
          // Controller not ready yet
        }
      },
    );

    final zoomOutButton = IconButton(
      icon: const Icon(Icons.zoom_out),
      onPressed: () {
        try {
          _controller.zoomDown();
        } catch (e) {
          // Controller not ready yet
        }
      },
    );

    final QfqqHttpClient client = ref.read(qfqqHttpClientProvider);
    final headers = <String, String>{};
    client.addHeaders(headers);

    final viewer = PdfViewer.uri(
      client.getUri(widget.pdfUrl),
      controller: _controller,
      headers: headers,
    );

    return Stack(
      children: [
        viewer,
        Positioned(
          top: 16,
          right: 16,
          child: Card(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                downloadButton,
                const SizedBox(height: 8),
                zoomInButton,
                const SizedBox(height: 8),
                zoomOutButton,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
