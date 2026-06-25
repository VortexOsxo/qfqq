import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/utils/get_status_ui.dart';
import 'package:qfqq/common/widgets/dropdowns/default_dropdown_menu.dart';
import 'package:qfqq/generated/l10n.dart';

class ProjectDropdownMenu extends ConsumerWidget {
  final int? initialProject;
  final ValueChanged<int?> valueChanged;

  const ProjectDropdownMenu({
    super.key,
    required this.initialProject,
    required this.valueChanged,
  });

  String getStatusLabel(BuildContext context, MeetingAgendaStatus status) {
    var loc = S.of(context);
    var ui = getMeetingAgendaStatusUI(loc, status);
    return '${loc.attributeStatus}: ${ui.label}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var projects = ref.watch(projectsProvider);

    final List<DropdownMenuEntry<int?>> menuEntries = UnmodifiableListView([
      DropdownMenuEntry<int?>(
        value: null,
        label: S.of(context).agendaListAnyProject,
      ),
      DropdownMenuEntry<int?>(
        value: -1,
        label: S.of(context).agendaListNoProject,
      ),

      ...projects.map(
        (project) => DropdownMenuEntry<int?>(
          value: project.id,
          label: '${S.of(context).attributeProject}: ${project.title}',
        ),
      ),
    ]);
    return DefaultDropdownMenu<int?>(
      entries: menuEntries,
      initialSelection: initialProject,
      onSelected: valueChanged,
    );
  }
}
