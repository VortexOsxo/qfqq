import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/utils/get_status_ui.dart';
import 'package:qfqq/common/widgets/dropdowns/default_dropdown_menu.dart';
import 'package:qfqq/generated/l10n.dart';

class ProjectStatusDropdownMenu extends StatelessWidget {
  final ProjectStatus? initialStatus;
  final ValueChanged<ProjectStatus?> valueChanged;

  const ProjectStatusDropdownMenu({
    super.key,
    required this.initialStatus,
    required this.valueChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final entries = UnmodifiableListView([
      DropdownMenuEntry<ProjectStatus?>(
        value: null,
        label: loc.agendaListAnyStatus,
      ),
      ...ProjectStatus.values.map(
        (status) => DropdownMenuEntry<ProjectStatus?>(
          value: status,
          label:
              '${loc.attributeStatus}: ${getProjectStatusUI(loc, status).label}',
        ),
      ),
    ]);

    return DefaultDropdownMenu<ProjectStatus?>(
      entries: entries,
      initialSelection: initialStatus,
      onSelected: valueChanged,
    );
  }
}
