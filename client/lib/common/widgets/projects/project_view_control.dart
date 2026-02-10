import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/providers/project_view_content_provider.dart';
import 'package:qfqq/generated/l10n.dart';

class ProjectViewControl extends ConsumerWidget {
  final Project project;
  const ProjectViewControl({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void changeContent(String content) {
      final service = ref.read(projectViewContentProvider.notifier);
      service.changeContent(content);
    }

    final content = ref.watch(projectViewContentProvider);

    final loc = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton(
          child: Text(loc.commonModify),
          onPressed: () => context.go('/project/creation', extra: project),
        ),
        SizedBox(child: Divider()),
        TextButton(
          onPressed: () => changeContent('decisions'),
          style: TextButton.styleFrom(
            foregroundColor:
                content == 'decisions' ? Colors.blueAccent : Colors.black,
          ),
          child: Text(loc.commonObjectDecisions),
        ),
        TextButton(
          onPressed: () => changeContent('reports'),
          style: TextButton.styleFrom(
            foregroundColor:
                content == 'reports' ? Colors.blueAccent : Colors.black,
          ),
          child: Text(loc.commonObjectReports),
        ),
      ],
    );
  }
}
