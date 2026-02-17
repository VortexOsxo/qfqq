import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/providers/decisions_provider.dart';
import 'package:qfqq/common/utils/is_id_valid.dart';
import 'package:qfqq/common/widgets/default_text_field.dart';
import 'package:qfqq/common/widgets/reusables/user_text_field.dart';
import 'package:qfqq/common/widgets/reusables/users_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

class MeetingViewContentOngoing extends ConsumerStatefulWidget {
  final MeetingAgenda meeting;

  const MeetingViewContentOngoing({super.key, required this.meeting});

  @override
  ConsumerState<MeetingViewContentOngoing> createState() =>
      _MeetingViewContentOngoing();
}

class _MeetingViewContentOngoing extends ConsumerState<MeetingViewContentOngoing> {
  Decision decision = Decision.empty();

  @override
  Widget build(BuildContext context) {
    final decisionsService = ref.read(decisionsServiceProvider);
    final loc = S.of(context);

    if (decision.meetingId == null && isIdValid(widget.meeting.id)) {
      decision.meetingId = widget.meeting.id;
    }

    return Center(
      child: Column(
        children: [
          Text(loc.meetingInProgressTakeDecision),
          Padding(
            padding: EdgeInsets.all(8),
            child: DefaultTextField(
              onChanged: (String desc) => decision.description = desc,
              hintText: loc.meetingInProgressDecision,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: UserTextField(
              label: loc.meetingInProgressResponsible,
              onSelected: (User u) => decision.responsibleId = u.id,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: UsersTextField(
              onChanged:
                  (List<User> u) =>
                      decision.assistantsIds = u.map((u) => u.id).toList(),
              label: loc.meetingInProgressParticipants,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: decision.dueDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );

                if (picked != null) {
                  decision.dueDate = picked;
                }
              },
              child: Text(
                decision.dueDate == null
                    ? loc.meetingInProgressDueDate
                    : loc.meetingInProgressDueDateSelected(
                      decision.dueDate!.toIso8601String().split('T').first,
                    ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              decisionsService.createDecision(decision);
              setState(
                () =>
                    decision = Decision.empty()..projectId = widget.meeting.projectId,
              );
            },
            child: Text(loc.meetingInProgressCreateButton),
          ),
        ],
      ),
    );
  }
}
