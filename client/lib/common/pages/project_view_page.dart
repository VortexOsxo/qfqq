import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/templates/page_template.dart';
import 'package:qfqq/common/widgets/projects/project_content_widget.dart';
import 'package:qfqq/common/widgets/projects/project_view_control.dart';
import 'package:qfqq/generated/l10n.dart';

class ProjectViewPage extends ConsumerWidget {
  final String projectId;
  const ProjectViewPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);
    String title = loc.projectViewPageTitle;

    final project = ref.watch(projectProviderById(projectId));
    if (project == null) {
      return buildPageTemplate(
        context,
        Center(child: Text(loc.projectNotFound)),
        title,
      );
    }

    Widget content = Center(
      child: Column(
        children: [
          buildInfoCard(context, ref, project),
          SizedBox(height: 16),
          Expanded(
            child: ProjectContentWidget(projectId: projectId)
          ),
        ],
      ),
    );

    return buildPageTemplate(context, content, title);
  }

  Widget buildInfoCard(BuildContext context, WidgetRef ref, Project project) {
    final supervisor = ref.watch(userByIdProvider(project.supervisorId));

    final leftCard = Expanded(
      flex: 2,
      child: Card(child: ProjectViewControl(project: project)),
    );

    final middleCard = Expanded(
      flex: 4,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${project.number}: ${project.title}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(project.goals),
            ],
          ),
        ),
      )
    );

    final rightCard = Expanded(
      flex: 2,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('${S.of(context).projectSupervisor}: ${supervisor?.username}'),
        ),
      )
    );

    final space = Expanded(flex: 1, child: SizedBox());

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [leftCard, space, middleCard, space, rightCard],
      ),
    );
  }
}
