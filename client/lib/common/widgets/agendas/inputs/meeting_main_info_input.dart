import 'package:flutter/material.dart';
import 'package:qfqq/common/models/errors/meeting_agenda_errors.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/templates/form_template.dart';
import 'package:qfqq/common/widgets/reusables/default_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

class MeetingMainInfoInput extends StatelessWidget {
  final MeetingAgenda meeting;
  final MeetingAgendaErrors errors;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onGoalsChanged;

  const MeetingMainInfoInput({
    super.key,
    required this.meeting,
    required this.errors,
    required this.onTitleChanged,
    required this.onGoalsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildLabel(context, loc.agendaPageTitle),
        DefaultTextField(
          initialValue: meeting.title,
          hintText: loc.agendaPageTitleHint,
          onChanged: onTitleChanged,
          error: errors.titleError,
        ),

        const SizedBox(height: 20),

        buildLabel(context, loc.agendaPageGoals),
        DefaultTextField(
          initialValue: meeting.goals ?? '',
          hintText: loc.agendaPageGoalsHint,
          onChanged: onGoalsChanged,
          error: errors.goalsError,
          maxLines: 5,
        ),
      ],
    );
  }
}
