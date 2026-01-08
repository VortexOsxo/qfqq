import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/providers/decisions_provider.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/templates/page_template.dart';
import 'package:qfqq/common/widgets/default_text_field.dart';
import 'package:qfqq/common/widgets/reusables/project_text_field.dart';
import 'package:qfqq/common/widgets/reusables/user_text_field.dart';
import 'package:qfqq/common/widgets/reusables/users_text_field.dart';

class MeetingInProgressPage extends ConsumerWidget {
  final String id;
  final Decision decision = Decision.empty();

  MeetingInProgressPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decisionsService = ref.read(decisionsServiceProvider);

    final agenda = ref.watch(meetingAgendaByIdProvider(id));
    assert(agenda != null, "Meeting in progress should not allow invalid id");
    if (decision.projectId == null && agenda!.projectId != null) {
      decision.projectId = agenda.projectId ?? '';
    }

    Widget content = Center(
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 250, height: 75),
                  Column(
                    children: [
                      Text(
                        agenda!.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(agenda.reunionGoals),
                    ],
                  ),

                  Container(
                    width: 250,
                    height: 75,
                    padding: EdgeInsets.all(8),
                    child: ProjectTextField(
                      label: 'Project',
                      initialProjectId: agenda.projectId ?? '',
                      onSelected: (Project p) => decision.projectId = p.id,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 32),

          Text('Take a Decision: '),
          DefaultTextField(
            onChanged: (String desc) => decision.description = desc,
            hintText: 'Decision',
          ),
          UserTextField(
            label: 'Responsible',
            onSelected: (User u) => decision.responsibleId = u.id,
          ),
          UserTextField(
            label: 'Reporter',
            onSelected: (User u) => decision.reporterId = u.id,
          ),
          UsersTextField(
            onChanged:
                (List<User> u) =>
                    decision.assistantsIds = u.map((u) => u.id).toList(),
            label: "Participants",
          ),
          ElevatedButton(
            onPressed: () => decisionsService.createDecision(decision),
            child: Text('Create'),
          ),
        ],
      ),
    );

    return buildPageTemplate(context, content, "Meeting in progress");
  }
}
