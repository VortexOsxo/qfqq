import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/templates/page_template.dart';
import 'package:qfqq/common/widgets/editable_text_widget.dart';
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
      return buildPageTemplate(context, Center(child: Text(loc.projectNotFound)), title);
    }

    Widget content = Center(
      child: Column(
        children: [
          Text(project.title),
          Text(project.description),
          EditableTextWidget(
            initialValue: project.title,
            onSave: (newTitle) {},
          ),
        ],
      ),
    );

    return buildPageTemplate(context, content, title);
  }
}
