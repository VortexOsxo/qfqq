import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/templates/page_template.dart';
import 'package:qfqq/common/utils/is_id_valid.dart';
import 'package:qfqq/common/widgets/decisions/decisions_list_widget.dart';
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

    bool filterFunc(Decision decision) {
      if (!isIdValid(project.id)) return false;
      return decision.projectId == project.id;
    }

    Widget content = Center(
      child: Column(
        children: [
          buildInfoCard(context, ref, project),
          SizedBox(height: 16),
          Expanded(
            child: DecisionsListWidget(
              isProjectFilterEnabled: false,
              filterFunction: filterFunc,
            ),
          ),
        ],
      ),
    );

    return buildPageTemplate(context, content, title);
  }

  Widget buildInfoCard(BuildContext context, WidgetRef ref, Project project) {
    final supervisor = ref.watch(userByIdProvider(project.supervisorId));

    final leftCard = Card(
      child: OutlinedButton(
        child: Text('Modify'),
        onPressed: () => context.go('/project/creation', extra: project),
      ),
    );

    final middleCard = Card(
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
    );

    final rightCard = Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('${S.of(context).projectSupervisor}: ${supervisor?.username}'),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [leftCard, middleCard, rightCard],
      ),
    );
  }
}
