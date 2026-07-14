import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/widgets/pdf_viewer_widget.dart';

class ParticipantsReport extends ConsumerWidget {
  const ParticipantsReport({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PdfViewerWidget(
            pdfUrl: 'reports/participants',
            pdfName: 'participants-report',
          );
  }
}
