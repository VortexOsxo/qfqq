export 'report_options_dialog.dart' show DecisionReportFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/configs/report_config.dart';
import 'package:qfqq/common/widgets/pdf_viewer_widget.dart';
import 'package:qfqq/common/widgets/report_options_dialog.dart';
import 'package:qfqq/generated/l10n.dart';

class ReportPdfViewer extends ConsumerStatefulWidget {
  final ReportConfig config;
  final void Function(DecisionReportFilter filter)? onFilterApplied;

  const ReportPdfViewer({
    super.key,
    required this.config,
    this.onFilterApplied,
  });

  @override
  ConsumerState<ReportPdfViewer> createState() => _ReportPdfViewerState();
}

class _ReportPdfViewerState extends ConsumerState<ReportPdfViewer> {
  bool _showComments = true;
  late Set<int> _selectedColumns;
  DecisionReportFilter _appliedFilter = const DecisionReportFilter();

  @override
  void initState() {
    super.initState();
    _selectedColumns = widget.config.availableColumns.toSet();
  }

  String get _currentPdfUrl {
    final queryParams = {
      ..._appliedFilter.toQueryParams(),
      'columns': reportColumnsQueryValue(_selectedColumns),
      if (widget.config.hasComments) 'showComments': _showComments.toString(),
    };
    final uri = Uri.parse(widget.config.pdfUrl);
    final merged = {...uri.queryParameters, ...queryParams};
    return uri.replace(queryParameters: merged).toString();
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Stack(
      children: [
        PdfViewerWidget(pdfUrl: _currentPdfUrl, pdfName: widget.config.pdfName),
        if (widget.config.availableColumns.isNotEmpty ||
            widget.config.hasFilter)
          Positioned(
            top: isMobile ? 80 : 64,
            right: 16,
            child: Card(
              child: IconButton(
                tooltip: loc.reportOptionsDialogTitle,
                onPressed: _openReportOptions,
                icon: Badge(
                  isLabelVisible: _appliedFilter.activeCount > 0,
                  label: Text(_appliedFilter.activeCount.toString()),
                  child: const Icon(Icons.tune),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _openReportOptions() async {
    final options = await showDialog<ReportDisplayOptions>(
      context: context,
      builder:
          (context) => ReportOptionsDialog(
            config: widget.config,
            selectedColumns: _selectedColumns,
            showReviews: _showComments,
            filter: _appliedFilter,
          ),
    );

    if (options == null || !mounted) return;
    setState(() {
      _selectedColumns = options.columns;
      _showComments = options.showReviews;
      _appliedFilter = options.filter;
    });
    widget.onFilterApplied?.call(options.filter);
  }
}
