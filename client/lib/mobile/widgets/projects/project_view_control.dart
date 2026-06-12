import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/view_models/project_view_page_view_model.dart';
import 'package:qfqq/common/widgets/reusables/tab_selection_widget.dart';
import 'package:qfqq/generated/l10n.dart';

class ProjectViewControl extends ConsumerWidget {
  final ProjectViewPageViewModelState vm;

  const ProjectViewControl({super.key, required this.vm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);

    return TabSelectionWidget(
      initialIndex: _contentToIndex(vm.selectedContent),
      labels: [loc.commonObjectDecisions, loc.commonObjectReports],
      axis: Axis.vertical,
      onTabSelected: (index) => vm.onContentChanged(_indexToContent(index)),
    );
  }

  int _contentToIndex(String content) {
    return content == 'decisions' ? 0 : 1;
  }

  String _indexToContent(int index) {
    return index == 0 ? 'decisions' : 'reports';
  }
}
