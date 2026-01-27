import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/providers/decisions_provider.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/templates/page_template.dart';
import 'package:qfqq/common/utils/is_id_valid.dart';
import 'package:qfqq/common/widgets/default_text_field.dart';
import 'package:qfqq/common/widgets/reusables/project_text_field.dart';
import 'package:qfqq/common/widgets/reusables/user_text_field.dart';
import 'package:qfqq/common/widgets/reusables/users_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

class MeetingInProgressPage extends ConsumerWidget {
  final String id;
  final Decision decision = Decision.empty();

  MeetingInProgressPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decisionsService = ref.read(decisionsServiceProvider);
    final loc = S.of(context);

    final agenda = ref.watch(meetingAgendaByIdProvider(id));
    assert(agenda != null, "Meeting in progress should not allow invalid id");

    if (decision.projectId == null && agenda!.projectId != null) {
      decision.projectId = agenda.projectId ?? '';
    }
    User? animator;
    if (isIdValid(agenda!.animatorId)) {
      animator = ref.watch(userByIdProvider(agenda.animatorId ?? ''));
    }

    Widget content = Center(
      child: Column(
        children: [
          _buildMeetingHeaderInfo(context, agenda, animator),
          SizedBox(height: 32),
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
          ElevatedButton(
            onPressed: () => decisionsService.createDecision(decision),
            child: Text(loc.meetingInProgressCreateButton),
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
        ],
      ),
    );

    return buildPageTemplate(context, content, loc.meetingInProgressPageTitle);
  }

  Widget _buildMeetingHeaderSide(Widget content, bool isLeft) {
    return Container(
      width: 250,
      height: 75,
      padding: EdgeInsets.all(8),
      child: Align(
        alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: content,
      ),
    );
  }

  Widget _buildMeetingHeaderInfo(
    BuildContext context,
    MeetingAgenda agenda,
    User? animator,
  ) {
    final loc = S.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMeetingHeaderSide(
              (animator != null)
                  ? Text(loc.meetingInProgressAnimator(animator.username))
                  : SizedBox.shrink(),
              true,
            ),
            Column(
              children: [
                Text(
                  agenda.title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Text(agenda.reunionGoals),
              ],
            ),
            _buildMeetingHeaderSide(
              ProjectTextField(
                label: loc.meetingInProgressProject,
                initialProjectId: agenda.projectId ?? '',
                onSelected: (Project p) => decision.projectId = p.id,
              ),
              false,
            ),
          ],
        ),
      ),
    );
  }
}
