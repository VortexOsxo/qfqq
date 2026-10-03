import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:qfqq/common/services/pdf_service.dart';
import 'package:qfqq/common/services/qfqq_http_client.dart';
import 'package:qfqq/common/widgets/report_send_modal.dart';

class PdfViewerWidget extends ConsumerStatefulWidget {
  final String pdfUrl;
  final String pdfName;

  const PdfViewerWidget({
    super.key,
    required this.pdfUrl,
    required this.pdfName,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _PdfViewerState();
  }
}

class _PdfViewerState extends ConsumerState<PdfViewerWidget> {
  final PdfViewerController _controller = PdfViewerController();
  double? _zoomFactor;

  @override
  void didUpdateWidget(covariant PdfViewerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pdfUrl != widget.pdfUrl && _controller.isReady) {
      _zoomFactor = _controller.currentZoom / _controller.coverScale;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sendButton = IconButton(
      icon: const Icon(Icons.send),
      onPressed:
          () => showDialog(
            context: context,
            barrierDismissible: true,
            builder: (_) => ReportSendModal(pdfUrl: widget.pdfUrl),
          ),
    );

    final downloadButton = IconButton(
      icon: const Icon(Icons.download),
      onPressed: () async {
        await ref
            .read(pdfServiceProvider)
            .downloadPdfToDownloads(widget.pdfUrl, widget.pdfName);
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
      params: PdfViewerParams(
        calculateInitialZoom: (_, controller, fitZoom, coverZoom) {
          final zoomFactor = _zoomFactor;
          final zoom = zoomFactor == null ? fitZoom : coverZoom * zoomFactor;
          return zoom
              .clamp(controller.minScale, controller.params.maxScale)
              .toDouble();
        },
      ),
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
                sendButton,
                const SizedBox(height: 8),
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
