import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MaxLengthEnforcement;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/models/configs/report_config.dart';
import 'package:qfqq/common/models/configs/saved_report_config.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/services/modal_service.dart';
import 'package:qfqq/common/services/reports_service.dart';
import 'package:qfqq/common/widgets/dropdowns/decision_status_dropdown_menu.dart';
import 'package:qfqq/common/widgets/dropdowns/default_dropdown_menu.dart';
import 'package:qfqq/common/widgets/dropdowns/user_dropdown_menu.dart';
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

class ReportDisplayOptions {
  final Set<int> columns;
  final bool showReviews;
  final DecisionReportFilter filter;

  const ReportDisplayOptions({
    required this.columns,
    required this.showReviews,
    required this.filter,
  });
}

String reportColumnsQueryValue(Set<int> columns) =>
    columns.isEmpty ? 'set()' : '{${columns.join(',')}}';

class ReportOptionsDialog extends ConsumerStatefulWidget {
  final ReportConfig config;
  final Set<int> selectedColumns;
  final bool showReviews;
  final DecisionReportFilter filter;

  const ReportOptionsDialog({
    super.key,
    required this.config,
    required this.selectedColumns,
    required this.showReviews,
    required this.filter,
  });

  @override
  ConsumerState<ReportOptionsDialog> createState() =>
      _ReportOptionsDialogState();
}

class _ReportOptionsDialogState extends ConsumerState<ReportOptionsDialog> {
  late Set<int> _columns;
  late bool _showReviews;
  late int? _projectId;
  late int? _responsibleId;
  late DecisionStatus? _status;
  final _nameController = TextEditingController();
  bool _showSaveInput = false;
  bool _isSaving = false;
  bool _isDeleting = false;
  int? _selectedSavedConfigId;
  late Future<List<SavedReportConfig>> _savedConfigsFuture;

  @override
  void initState() {
    super.initState();
    _columns = widget.selectedColumns.toSet();
    _showReviews = widget.showReviews;
    _projectId = widget.filter.projectId;
    _responsibleId = widget.filter.responsibleId;
    _status = widget.filter.status;
    _savedConfigsFuture = _loadSavedConfigs();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final theme = Theme.of(context);
    final dropdownWidth = (MediaQuery.sizeOf(context).width - 120).clamp(
      200.0,
      360.0,
    );
    final projectEntries = <DropdownMenuEntry<int?>>[
      DropdownMenuEntry<int?>(value: null, label: loc.agendaListAnyProject),
      ...ref
          .read(projectsProvider)
          .map(
            (project) => DropdownMenuEntry<int?>(
              value: project.id,
              label: '${loc.commonProject}: ${project.title}',
            ),
          ),
    ];

    return AlertDialog(
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
                _buildSavedConfigSelector(loc, theme, dropdownWidth),
                const SizedBox(height: 16),
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
                      key: ValueKey('status-$_status'),
                      initialStatus: _status,
                      width: dropdownWidth,
                      valueChanged: (value) => setState(() => _status = value),
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
                      key: ValueKey('responsible-$_responsibleId'),
                      initialUserId: _responsibleId,
                      anyLabel: loc.decisionListAnyResponsible,
                      width: dropdownWidth,
                      valueChanged:
                          (value) => setState(() => _responsibleId = value),
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (widget.config.hasProjectFilter) ...[
                    Text(loc.commonProject, style: theme.textTheme.labelLarge),
                    const SizedBox(height: 6),
                    DefaultDropdownMenu<int?>(
                      key: ValueKey('project-$_projectId'),
                      initialSelection: _projectId,
                      width: dropdownWidth,
                      onSelected: (value) => setState(() => _projectId = value),
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
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(_columnLabel(loc, column)),
                      value: _columns.contains(column),
                      onChanged: (value) {
                        setState(() {
                          if (value ?? false) {
                            _columns.add(column);
                          } else {
                            _columns.remove(column);
                          }
                        });
                      },
                    ),
                  ),
                  if (widget.config.hasComments)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(loc.reportShowReviews),
                      value: _showReviews,
                      onChanged:
                          (value) =>
                              setState(() => _showReviews = value ?? false),
                    ),
                ],
                if (_showSaveInput) _saveReportWidget(loc),
              ],
            ),
          ),
        ),
      ),
      actions: [
        if (!_showSaveInput)
          TextButton(
            onPressed: () => setState(() => _showSaveInput = true),
            child: Text(loc.commonSave),
          ),
        TextButton(onPressed: _reset, child: Text(loc.commonReset)),
        FilledButton(
          onPressed:
              () => Navigator.pop(
                context,
                ReportDisplayOptions(
                  columns: _columns,
                  showReviews: _showReviews,
                  filter: _currentFilter,
                ),
              ),
          child: Text(loc.commonConfirm),
        ),
      ],
    );
  }

  DecisionReportFilter get _currentFilter => DecisionReportFilter(
    projectId: _projectId,
    responsibleId: _responsibleId,
    status: _status,
  );

  Future<List<SavedReportConfig>> _loadSavedConfigs() =>
      ref.read(reportsServiceProvider).getReportConfigs();

  Widget _buildSavedConfigSelector(
    S loc,
    ThemeData theme,
    double dropdownWidth,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeading(
          loc.reportConfigOpen,
          Icons.folder_open_outlined,
          theme,
        ),
        FutureBuilder<List<SavedReportConfig>>(
          future: _savedConfigsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snapshot.hasError) {
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      loc.errorUnknown,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                  IconButton(
                    tooltip: loc.commonRetry,
                    onPressed: () {
                      setState(() => _savedConfigsFuture = _loadSavedConfigs());
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              );
            }

            final configs = snapshot.data ?? const <SavedReportConfig>[];
            if (configs.isEmpty) {
              return Text(
                loc.reportConfigNone,
                style: theme.textTheme.bodySmall,
              );
            }

            SavedReportConfig? selectedConfig;
            for (final config in configs) {
              if (config.id == _selectedSavedConfigId) {
                selectedConfig = config;
                break;
              }
            }
            final configToDelete = selectedConfig;

            return Row(
              children: [
                Expanded(
                  child: DefaultDropdownMenu<int?>(
                    key: ValueKey(_selectedSavedConfigId),
                    entries: [
                      DropdownMenuEntry<int?>(
                        value: null,
                        label: loc.reportConfigOpen,
                      ),
                      ...configs.map(
                        (config) => DropdownMenuEntry<int?>(
                          value: config.id,
                          label: config.name,
                        ),
                      ),
                    ],
                    initialSelection: _selectedSavedConfigId,
                    width: dropdownWidth,
                    onSelected: (id) {
                      if (id == null) return;
                      final config = configs.firstWhere(
                        (item) => item.id == id,
                      );
                      _applySavedConfig(config);
                    },
                  ),
                ),
                IconButton(
                  tooltip: loc.commonDelete,
                  onPressed:
                      configToDelete == null || _isDeleting
                          ? null
                          : () => _deleteSavedConfig(configToDelete),
                  icon:
                      _isDeleting
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.delete_outline),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _applySavedConfig(SavedReportConfig config) {
    setState(() {
      _selectedSavedConfigId = config.id;
      _columns =
          config.columns.where(widget.config.availableColumns.contains).toSet();
      _showReviews = config.showReviews;
      _projectId =
          widget.config.hasProjectFilter
              ? _parseFilterId(config.filters['projectId'])
              : null;
      _responsibleId =
          widget.config.hasResponsibleFilter
              ? _parseFilterId(config.filters['responsibleId'])
              : null;
      _status =
          widget.config.hasStatusFilter
              ? _parseStatus(config.filters['status'])
              : null;
    });
  }

  int? _parseFilterId(Object? value) {
    if (value is int) return value;
    return value is String ? int.tryParse(value) : null;
  }

  Future<void> _deleteSavedConfig(SavedReportConfig config) async {
    final loc = S.of(context);
    final confirmed = await ModalService.showConfirmation(
      context: context,
      title: loc.reportConfigDeleteTitle,
      message: loc.reportConfigDeleteConfirmation(config.name),
      confirmLabel: loc.commonDelete,
      cancelLabel: loc.commonCancel,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isDeleting = true);
    final bool deleted;
    try {
      deleted = await ref
          .read(reportsServiceProvider)
          .deleteReportConfig(config.id);
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }

    if (!mounted) return;
    if (deleted) {
      setState(() {
        _selectedSavedConfigId = null;
        _savedConfigsFuture = _loadSavedConfigs();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.reportConfigDeleted)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.errorUnknown), backgroundColor: Colors.red),
      );
    }
  }

  DecisionStatus? _parseStatus(Object? value) {
    if (value is! String) return null;
    for (final status in DecisionStatus.values) {
      if (status.name == value) return status;
    }
    return null;
  }

  void _reset() {
    setState(() {
      _projectId = null;
      _responsibleId = null;
      _status = null;
      _columns = widget.config.availableColumns.toSet();
      _showReviews = true;
      _selectedSavedConfigId = null;
    });
  }

  Widget _saveReportWidget(S loc) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _nameController,
            autofocus: true,
            maxLength: 30,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: loc.reportConfigName,
              counterText: '',
            ),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed:
              _nameController.text.trim().isEmpty || _isSaving
                  ? null
                  : _saveReportConfig,
          child:
              _isSaving
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Text(loc.commonSave),
        ),
      ],
    );
  }

  Future<void> _saveReportConfig() async {
    setState(() => _isSaving = true);
    final bool saved;
    try {
      saved = await ref
          .read(reportsServiceProvider)
          .saveReportConfig(
            name: _nameController.text.trim(),
            parameters: {
              'columns': reportColumnsQueryValue(_columns),
              ..._currentFilter.toQueryParams(),
              'showComments': _showReviews.toString(),
            },
          );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }

    if (!mounted) return;
    if (saved) {
      _nameController.clear();
      setState(() {
        _showSaveInput = false;
        _savedConfigsFuture = _loadSavedConfigs();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).reportConfigSaved)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).errorUnknown),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  String _columnLabel(S loc, int column) => switch (column) {
    ReportConfig.numberColumn => loc.reportColumnNumber,
    ReportConfig.meetingColumn => loc.reportColumnMeetingNumber,
    ReportConfig.descriptionColumn => loc.commonAction,
    ReportConfig.responsibleColumn => loc.decisionListResponsible,
    ReportConfig.dueDateColumn => loc.reportColumnDueDate,
    ReportConfig.statusColumn => loc.attributeStatus,
    ReportConfig.completedDateColumn => loc.reportColumnCompletedDate,
    ReportConfig.completionMessageColumn => loc.decisionCompletionMessageLabel,
    _ => column.toString(),
  };
}
