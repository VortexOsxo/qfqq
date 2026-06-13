import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/utils/get_status_ui.dart';
import 'package:qfqq/common/widgets/dropdowns/default_dropdown_menu.dart';
import 'package:qfqq/generated/l10n.dart';

class AgendaStatusDropdownMenu extends StatelessWidget {
  final MeetingAgendaStatus? initialStatus;
  final ValueChanged<MeetingAgendaStatus?> valueChanged;

  const AgendaStatusDropdownMenu({
    super.key,
    required this.initialStatus,
    required this.valueChanged,
  });

  String getStatusLabel(BuildContext context, MeetingAgendaStatus status) {
    var loc = S.of(context);
    var ui = getMeetingAgendaStatusUI(loc, status);
    return '${loc.attributeStatus}: ${ui.label}';
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuEntry<MeetingAgendaStatus?>> menuEntries =
        UnmodifiableListView([
          DropdownMenuEntry<MeetingAgendaStatus?>(
            value: null,
            label: S.of(context).agendaListAnyStatus,
          ),
          ...MeetingAgendaStatus.values.map(
            (status) => DropdownMenuEntry<MeetingAgendaStatus?>(
              value: status,
              label: getStatusLabel(context, status),
            ),
          ),
        ]);

    return DefaultDropdownMenu<MeetingAgendaStatus?>(
      entries: menuEntries,
      initialSelection: initialStatus,
      onSelected: valueChanged,
    );
  }
}
