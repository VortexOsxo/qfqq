import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:qfqq/common/services/pdf_service.dart';

class PdfViewerWidget extends StatefulWidget {
  final String pdfUrl;

  const PdfViewerWidget({super.key, required this.pdfUrl});

  @override
  State<StatefulWidget> createState() {
    return _PdfViewerState();
  }
}

class _PdfViewerState extends State<PdfViewerWidget> {
  final PdfViewerController _controller = PdfViewerController();

  @override
  Widget build(BuildContext context) {
    final downloadButton = IconButton(
      icon: const Icon(Icons.download),
      onPressed: () async {
        await PdfService().downloadPdfToDownloads(widget.pdfUrl);
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

    final viewer = PdfViewer.uri(
      Uri.parse(widget.pdfUrl),
      controller: _controller,
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
