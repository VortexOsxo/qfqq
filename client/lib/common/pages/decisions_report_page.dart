import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/widgets/pdf_viewer_widget.dart';
import 'package:qfqq/generated/l10n.dart';

class DecisionsReportPage extends ConsumerWidget {
  const DecisionsReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsetsGeometry.all(8),
            child: ElevatedButton(
              onPressed: () => context.go('/decisions'),
              style: squareButtonStyle(context),
              child: Text(loc.commonBack),
            ),
          ),
        ),
        Expanded(
          child: const PdfViewerWidget(
            pdfUrl: 'reports/participants',
            pdfName: 'participants-report',
          ),
        ),
      ],
    );
  }
}
