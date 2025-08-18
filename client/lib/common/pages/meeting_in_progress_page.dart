import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/providers/decisions_provider.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/widgets/common_app_bar.dart';
import 'package:qfqq/common/widgets/default_text_field.dart';
import 'package:qfqq/common/widgets/project_selection_dropdown_widget.dart';
import 'package:qfqq/common/widgets/user_selection_dropdown_widget.dart';
import 'package:qfqq/common/widgets/users_selection_dropdown_widget.dart';

class MeetingInProgressPage extends ConsumerWidget {
  final String id;

  const MeetingInProgressPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agenda = ref.watch(meetingAgendaByIdProvider(id));
    final decisionsService = ref.read(decisionsProvider.notifier);

    final String title = agenda?.title ?? "Hi";

    Project? project;
    User? responsible;
    List<User> assistants = [];

    TextEditingController descriptionController = TextEditingController();

    return Scaffold(
      appBar: CommonAppBar(title: "Meeting in progress"),
      body: Center(
        child: Column(
          children: [
            Text(title),
            DefaultTextField(
              controller: descriptionController,
              hintText: 'Decision',
            ),
            ProjectSelectionDropdownWidget(
              onSelected: (Project? p) {
                project = p;
              },
            ),
            UserSelectionDropdownWidget(
              onSelected: (User? u) {
                responsible = u;
              },
              text: "Responsible",
            ),
            UsersSelectionDropdownWidget(
              onSelected: (List<User> u) {
                assistants = u;
              },
              text: "Participants",
            ),
            ElevatedButton(
              onPressed: () {
                decisionsService.createDecision(
                  description: descriptionController.text,
                  projectId: project?.id,
                  responsibleId: responsible?.id,
                  assistantsId: assistants.map((e) => e.id).toList(),
                );
              },
              child: Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
