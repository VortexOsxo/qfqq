import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/providers/decisions_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/utils/is_id_valid.dart';
import 'package:qfqq/common/widgets/reusables/default_text_field.dart';
import 'package:qfqq/common/widgets/reusables/selection_text_fields/user_text_field.dart';
import 'package:qfqq/common/widgets/reusables/selection_text_fields/users_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

class MeetingViewContentOngoing extends ConsumerStatefulWidget {
  final MeetingAgenda meeting;

  const MeetingViewContentOngoing({super.key, required this.meeting});

  @override
  ConsumerState<MeetingViewContentOngoing> createState() =>
      _MeetingViewContentOngoing();
}

class _MeetingViewContentOngoing
    extends ConsumerState<MeetingViewContentOngoing> {
  Decision decision = Decision.empty();
  late int _resetCounter = 0;

  @override
  Widget build(BuildContext context) {
    final decisionsService = ref.read(decisionsServiceProvider);
    final loc = S.of(context);
    final decisions = ref.watch(decisionsProvider);

    if (decision.meetingId == null && isIdValid(widget.meeting.id)) {
      decision.meetingId = widget.meeting.id;
    }

    final meetingDecisions = decisions
        .where((d) => d.meetingId == widget.meeting.id)
        .toList();

    return Center(
      child: Column(
        children: [
          Text(loc.meetingInProgressTakeDecision),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: DefaultTextField(
                    key: ValueKey(_resetCounter),
                    onChanged: (String desc) => decision.description = desc,
                    hintText: loc.meetingInProgressDecision,
                  ),
                ),
                TextButton(
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
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: UserTextField(
              key: ValueKey(_resetCounter),
              label: loc.meetingInProgressResponsible,
              onSelected: (User u) => decision.responsibleId = u.id,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: UsersTextField(
              key: ValueKey(_resetCounter),
              onChanged:
                  (List<User> u) =>
                      decision.assistantsIds = u.map((u) => u.id).toList(),
              label: loc.meetingInProgressParticipants,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await decisionsService.createDecision(decision);
              _resetCounter++;
              setState(
                () =>
                    decision =
                        Decision.empty()..projectId = widget.meeting.projectId,
              );
            },
            child: Text(loc.meetingInProgressCreateButton),
          ),
          if (meetingDecisions.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: meetingDecisions.length,
                itemBuilder: (context, index) {
                  final revIndex = meetingDecisions.length - 1 - index;
                  final decision = meetingDecisions[revIndex];
                  final responsible = decision.responsibleId != null ? ref.watch(userByIdProvider(decision.responsibleId!)) : null;
                  return ListTile(
                    title: Text(decision.description),
                    subtitle: Row(
                      children: [
                        if (responsible != null)
                          Expanded(
                            child: Text(
                              '${loc.decisionListResponsible}: ${responsible.displayName}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (decision.dueDate != null)
                          Expanded(
                            child: Text(
                              '${loc.decisionListDueDate}: ${decision.dueDate!.toIso8601String().split('T').first}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
