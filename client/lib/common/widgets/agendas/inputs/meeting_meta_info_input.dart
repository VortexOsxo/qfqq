import 'package:flutter/material.dart';
import 'package:qfqq/common/models/errors/meeting_agenda_errors.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/templates/form_template.dart';
import 'package:qfqq/common/widgets/agendas/inputs/agenda_date_picker.dart';
import 'package:qfqq/common/widgets/reusables/default_text_field.dart';
import 'package:qfqq/common/widgets/reusables/selection_text_fields/project_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

class MeetingMetaInfoInput extends StatelessWidget {
  final MeetingAgenda meeting;
  final MeetingAgendaErrors errors;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<String> onLocationSelected;
  final ValueChanged<Project> onProjectSelected;

  const MeetingMetaInfoInput({
    super.key,
    required this.meeting,
    required this.errors,
    required this.onDateSelected,
    required this.onLocationSelected,
    required this.onProjectSelected,
  });

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildLabel(context, loc.agendaPageProjectLabel),
        ProjectTextField(
          label: loc.agendaPageSelectProject,
          initialProjectId: meeting.projectId ?? 0,
          onSelected: onProjectSelected,
          error: errors.projectError,
        ),

        const SizedBox(height: 20),

        buildLabel(context, loc.attributeDate),
        AgendaDatePicker(
          meetingDate: meeting.meetingDate,
          meetingDateError: errors.meetingDateError,
          onSelected: onDateSelected,
        ),

        const SizedBox(height: 20),

        buildLabel(context, loc.attributeLocation),
        DefaultTextField(
          initialValue: meeting.meetingLocation ?? '',
          hintText: loc.agendaPageLocationHint,
          onChanged: onLocationSelected,
          error: errors.meetingLocationError,
        ),
      ],
    );
  }
}
