import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/models/configs/report_config.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/widgets/dropdowns/decision_status_dropdown_menu.dart';
import 'package:qfqq/common/widgets/dropdowns/default_dropdown_menu.dart';
import 'package:qfqq/common/widgets/dropdowns/user_dropdown_menu.dart';
import 'package:qfqq/common/widgets/pdf_viewer_widget.dart';
import 'package:qfqq/generated/l10n.dart';

class DecisionReportFilter {
  final int? projectId;
  final int? responsibleId;
  final DecisionStatus? status;

  const DecisionReportFilter({this.projectId, this.responsibleId, this.status});

  bool get isEmpty =>
      projectId == null && responsibleId == null && status == null;

  int get activeCount {
    var count = 0;
    if (projectId != null) count++;
    if (responsibleId != null) count++;
    if (status != null) count++;
    return count;
  }

  Map<String, String> toQueryParams() => {
    if (projectId != null) 'projectId': projectId.toString(),
    if (responsibleId != null) 'responsibleId': responsibleId.toString(),
    if (status != null) 'status': status!.name,
  };
}

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

class _ReportDisplayOptions {
  final Set<String> columns;
  final bool showReviews;
  final DecisionReportFilter filter;

  const _ReportDisplayOptions({
    required this.columns,
    required this.showReviews,
    required this.filter,
  });
}

class _ReportPdfViewerState extends ConsumerState<ReportPdfViewer> {
  bool _showComments = true;
  late Set<String> _selectedColumns;

  DecisionReportFilter _appliedFilter = const DecisionReportFilter();

  @override
  void initState() {
    super.initState();
    _selectedColumns = widget.config.availableColumns.toSet();
  }

  String get _currentPdfUrl {
    final queryParams = {
      ..._appliedFilter.toQueryParams(),
      'columns': _selectedColumns.join(','),
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
            child: _buildOptionsButton(loc),
          ),
      ],
    );
  }

  Widget _buildOptionsButton(S loc) {
    final activeCount = _appliedFilter.activeCount;

    return Card(
      child: IconButton(
        tooltip: loc.reportOptionsDialogTitle,
        onPressed: _openReportOptions,
        icon: Badge(
          isLabelVisible: activeCount > 0,
          label: Text(activeCount.toString()),
          child: const Icon(Icons.tune),
        ),
      ),
    );
  }

  Future<void> _openReportOptions() async {
    var columns = _selectedColumns.toSet();
    var showReviews = _showComments;
    var projectId = _appliedFilter.projectId;
    var responsibleId = _appliedFilter.responsibleId;
    var status = _appliedFilter.status;
    final loc = S.of(context);
    final theme = Theme.of(context);
    final dropdownWidth = (MediaQuery.sizeOf(context).width - 120).clamp(
      200.0,
      360.0,
    );

    final projectEntries = UnmodifiableListView<DropdownMenuEntry<int?>>([
      DropdownMenuEntry<int?>(value: null, label: loc.agendaListAnyProject),
      ...ref
          .read(projectsProvider)
          .map(
            (project) => DropdownMenuEntry<int?>(
              value: project.id,
              label: '${loc.commonProject}: ${project.title}',
            ),
          ),
    ]);

    final options = await showDialog<_ReportDisplayOptions>(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text(loc.reportOptionsDialogTitle),
                  content: SizedBox(
                    width:
                        MediaQuery.sizeOf(context).width < 540
                            ? MediaQuery.sizeOf(context).width - 80
                            : 460,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 560),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (widget.config.hasFilter) ...[
                              _buildSectionHeading(
                                loc.commonFilters,
                                Icons.filter_list,
                                theme,
                              ),
                              if (widget.config.hasStatusFilter) ...[
                                Text(
                                  loc.attributeStatus,
                                  style: theme.textTheme.labelLarge,
                                ),
                                const SizedBox(height: 6),
                                DecisionStatusDropdownMenu(
                                  key: ValueKey('status-$status'),
                                  initialStatus: status,
                                  width: dropdownWidth,
                                  valueChanged:
                                      (value) =>
                                          setDialogState(() => status = value),
                                ),
                                const SizedBox(height: 14),
                              ],
                              if (widget.config.hasResponsibleFilter) ...[
                                Text(
                                  loc.decisionListResponsible,
                                  style: theme.textTheme.labelLarge,
                                ),
                                const SizedBox(height: 6),
                                UserDropdownMenu(
                                  key: ValueKey('responsible-$responsibleId'),
                                  initialUserId: responsibleId,
                                  anyLabel: loc.decisionListAnyResponsible,
                                  width: dropdownWidth,
                                  valueChanged:
                                      (value) => setDialogState(
                                        () => responsibleId = value,
                                      ),
                                ),
                                const SizedBox(height: 14),
                              ],
                              if (widget.config.hasProjectFilter) ...[
                                Text(
                                  loc.commonProject,
                                  style: theme.textTheme.labelLarge,
                                ),
                                const SizedBox(height: 6),
                                DefaultDropdownMenu<int?>(
                                  key: ValueKey('project-$projectId'),
                                  initialSelection: projectId,
                                  width: dropdownWidth,
                                  onSelected:
                                      (value) => setDialogState(
                                        () => projectId = value,
                                      ),
                                  entries: projectEntries,
                                ),
                              ],
                              const SizedBox(height: 20),
                              const Divider(),
                              const SizedBox(height: 12),
                            ],
                            if (widget.config.availableColumns.isNotEmpty ||
                                widget.config.hasComments) ...[
                              _buildSectionHeading(
                                loc.reportOptionsTitle,
                                Icons.view_column_outlined,
                                theme,
                              ),
                              ...widget.config.availableColumns.map(
                                (column) => CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: Text(_columnLabel(loc, column)),
                                  value: columns.contains(column),
                                  onChanged: (value) {
                                    setDialogState(() {
                                      if (value ?? false) {
                                        columns.add(column);
                                      } else {
                                        columns.remove(column);
                                      }
                                    });
                                  },
                                ),
                              ),
                              if (widget.config.hasComments)
                                CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: Text(loc.reportShowReviews),
                                  value: showReviews,
                                  onChanged: (value) {
                                    setDialogState(
                                      () => showReviews = value ?? false,
                                    );
                                  },
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setDialogState(() {
                          projectId = null;
                          responsibleId = null;
                          status = null;
                          columns = widget.config.availableColumns.toSet();
                          showReviews = true;
                        });
                      },
                      child: Text(loc.commonReset),
                    ),
                    FilledButton(
                      onPressed:
                          () => Navigator.pop(
                            dialogContext,
                            _ReportDisplayOptions(
                              columns: columns,
                              showReviews: showReviews,
                              filter: DecisionReportFilter(
                                projectId: projectId,
                                responsibleId: responsibleId,
                                status: status,
                              ),
                            ),
                          ),
                      child: Text(loc.commonConfirm),
                    ),
                  ],
                ),
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

  Widget _buildSectionHeading(String title, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _columnLabel(S loc, String column) => switch (column) {
    'number' => loc.reportColumnNumber,
    'meetingId' => loc.reportColumnMeetingNumber,
    'description' => loc.commonAction,
    'responsible' => loc.decisionListResponsible,
    'dueDate' => loc.reportColumnDueDate,
    'status' => loc.attributeStatus,
    'completedDate' => loc.reportColumnCompletedDate,
    _ => column,
  };
}
