import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/providers/project_view_content_provider.dart';
import 'package:qfqq/common/widgets/reusables/tab_selection_widget.dart';
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
        TabSelectionWidget(
          initialIndex: _contentToIndex(content),
          labels: [
            loc.commonObjectDecisions,
            loc.commonObjectReports
          ],
          axis: Axis.vertical,
          onTabSelected: (index) {
            changeContent(_indexToContent(index));
          },
        ),
      ],
    );
  }

  int _contentToIndex(String content) {
    return content == 'decisions' ? 0 : 1;
  }

  String _indexToContent(int index) {
    return index == 0 ? 'decisions' : 'reports';
  }

}
