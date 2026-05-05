import 'package:flutter/material.dart';
import 'package:qfqq/common/models/errors/meeting_agenda_errors.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/templates/form_template.dart';
import 'package:qfqq/common/widgets/reusables/selection_text_fields/user_text_field.dart';
import 'package:qfqq/common/widgets/reusables/selection_text_fields/users_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

class MeetingPeopleInput extends StatelessWidget {
  final MeetingAgenda meeting;
  final MeetingAgendaErrors errors;
  final ValueChanged<User> onAnimatorChanged;
  final ValueChanged<List<User>> onParticipantsChanged;

  const MeetingPeopleInput({
    super.key,
    required this.meeting,
    required this.errors,
    required this.onAnimatorChanged,
    required this.onParticipantsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildLabel(context, loc.agendaPageFacilitator),

        UserTextField(
          label: loc.agendaPageAnimatorLabel,
          initialUserId: meeting.animatorId ?? 0,
          onSelected: onAnimatorChanged,
          error: errors.animatorError,
        ),

        const SizedBox(height: 20),

        buildLabel(context, loc.agendaPageParticipantsLabel),
        UsersTextField(
          label: loc.agendaPageAddParticipant,
          initialUsersIds: meeting.participantsIds,
          onChanged: onParticipantsChanged,
          error: errors.participantsError,
        ),
      ],
    );
  }
}
