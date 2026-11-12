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

  const _ReportDisplayOptions({
    required this.columns,
    required this.showReviews,
  });
}

class _ReportPdfViewerState extends ConsumerState<ReportPdfViewer> {
  bool _isExpanded = false;
  bool _showComments = true;
  late Set<String> _selectedColumns;

  int? _stagedProjectId;
  int? _stagedResponsibleId;
  DecisionStatus? _stagedStatus;

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

  void _applyFilters() {
    final newFilter = DecisionReportFilter(
      projectId: _stagedProjectId,
      responsibleId: _stagedResponsibleId,
      status: _stagedStatus,
    );
    setState(() {
      _appliedFilter = newFilter;
    });
    widget.onFilterApplied?.call(newFilter);
  }

  void _resetFilters() {
    setState(() {
      _stagedProjectId = null;
      _stagedResponsibleId = null;
      _stagedStatus = null;
      _appliedFilter = const DecisionReportFilter();
    });
    widget.onFilterApplied?.call(_appliedFilter);
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final theme = Theme.of(context);

    return Stack(
      children: [
        PdfViewerWidget(
          key: ValueKey(_currentPdfUrl),
          pdfUrl: _currentPdfUrl,
          pdfName: widget.config.pdfName,
        ),

        if (widget.config.availableColumns.isNotEmpty ||
            widget.config.hasFilter)
          Positioned(
            top: 64,
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isExpanded && widget.config.availableColumns.isNotEmpty)
                  _buildDisplayOptionsButton(loc),
                if (widget.config.hasFilter)
                  if (_isExpanded)
                    _buildExpandedFilterCard(context, loc, theme)
                  else
                    _buildFilterButton(loc),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDisplayOptionsButton(S loc) {
    return Card(
      child: IconButton(
        tooltip: loc.reportOptionsTitle,
        onPressed: _openDisplayOptions,
        icon: const Icon(Icons.view_column_outlined),
      ),
    );
  }

  Future<void> _openDisplayOptions() async {
    var columns = _selectedColumns.toSet();
    var showReviews = _showComments;

    final options = await showDialog<_ReportDisplayOptions>(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text(S.of(context).reportOptionsTitle),
                  content: SizedBox(
                    width: 380,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 420),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...widget.config.availableColumns.map(
                              (column) => CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: Text(
                                  _columnLabel(S.of(context), column),
                                ),
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
                                title: Text(S.of(context).reportShowReviews),
                                value: showReviews,
                                onChanged: (value) {
                                  setDialogState(
                                    () => showReviews = value ?? false,
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setDialogState(() {
                          columns = widget.config.availableColumns.toSet();
                          showReviews = true;
                        });
                      },
                      child: Text(S.of(context).commonReset),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(S.of(context).commonCancel),
                    ),
                    FilledButton(
                      onPressed:
                          () => Navigator.pop(
                            dialogContext,
                            _ReportDisplayOptions(
                              columns: columns,
                              showReviews: showReviews,
                            ),
                          ),
                      child: Text(S.of(context).commonConfirm),
                    ),
                  ],
                ),
          ),
    );

    if (options == null || !mounted) return;
    setState(() {
      _selectedColumns = options.columns;
      _showComments = options.showReviews;
    });
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

  Widget _buildFilterButton(S loc) {
    final activeCount = _appliedFilter.activeCount;

    return Card(
      child: IconButton(
        tooltip: loc.commonFilters,
        onPressed: () {
          setState(() {
            _stagedProjectId = _appliedFilter.projectId;
            _stagedResponsibleId = _appliedFilter.responsibleId;
            _stagedStatus = _appliedFilter.status;
            _isExpanded = true;
          });
        },
        icon: Badge(
          isLabelVisible: activeCount > 0,
          label: Text(activeCount.toString()),
          child: const Icon(Icons.filter_list),
        ),
      ),
    );
  }

  Widget _buildExpandedFilterCard(
    BuildContext context,
    S loc,
    ThemeData theme,
  ) {
    final projects = ref.watch(projectsProvider);

    final List<DropdownMenuEntry<int?>> projectEntries = UnmodifiableListView([
      DropdownMenuEntry<int?>(value: null, label: loc.agendaListAnyProject),
      ...projects.map(
        (project) => DropdownMenuEntry<int?>(
          value: project.id,
          label: '${loc.commonProject}: ${project.title}',
        ),
      ),
    ]);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Title + collapse button
            Row(
              children: [
                Icon(Icons.filter_list, size: 20, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  loc.commonFilters,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  tooltip: loc.commonCancel,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      _stagedProjectId = _appliedFilter.projectId;
                      _stagedResponsibleId = _appliedFilter.responsibleId;
                      _stagedStatus = _appliedFilter.status;
                      _isExpanded = false;
                    });
                  },
                ),
              ],
            ),
            const Divider(height: 20),

            if (widget.config.hasStatusFilter) ...[
              Text(
                loc.attributeStatus,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              DecisionStatusDropdownMenu(
                key: ValueKey('status-$_stagedStatus'),
                initialStatus: _stagedStatus,
                valueChanged: (status) {
                  setState(() => _stagedStatus = status);
                },
              ),
              const SizedBox(height: 12),
            ],

            if (widget.config.hasResponsibleFilter) ...[
              Text(
                loc.decisionListResponsible,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              UserDropdownMenu(
                key: ValueKey('responsible-$_stagedResponsibleId'),
                initialUserId: _stagedResponsibleId,
                anyLabel: loc.decisionListAnyResponsible,
                valueChanged: (userId) {
                  setState(() => _stagedResponsibleId = userId);
                },
              ),
              const SizedBox(height: 12),
            ],

            if (widget.config.hasProjectFilter) ...[
              Text(
                loc.commonProject,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              DefaultDropdownMenu<int?>(
                key: ValueKey('project-$_stagedProjectId'),
                initialSelection: _stagedProjectId,
                onSelected: (projectId) {
                  setState(() => _stagedProjectId = projectId);
                },
                entries: projectEntries,
              ),
              const SizedBox(height: 16),
            ],

            // Actions: Reset & Confirm
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _resetFilters,
                  child: Text(loc.commonReset),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _applyFilters,
                  child: Text(loc.commonConfirm),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
