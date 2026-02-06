import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/providers/project_view_content_provider.dart';
import 'package:qfqq/common/utils/is_id_valid.dart';
import 'package:qfqq/common/widgets/decisions/decisions_list_widget.dart';
import 'package:qfqq/common/widgets/pdf_viewer_widget.dart';

class ProjectContentWidget extends ConsumerWidget {
  final int projectId;

  const ProjectContentWidget({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(projectViewContentProvider);

    if (content == 'decisions') {
      return buildDecisionLists(context);
    }
    return buildReportViewer(context);
  }

  Widget buildDecisionLists(BuildContext context) {
    bool filterFunc(Decision decision) {
      if (!isIdValid(projectId)) return false;
      return decision.projectId == projectId;
    }

    return DecisionsListWidget(
      isProjectFilterEnabled: false,
      filterFunction: filterFunc,
    );
  }

  Widget buildReportViewer(BuildContext context) {
    final pdfUrl = 'http://localhost:5000/projects/$projectId/reports';

    return PdfViewerWidget(pdfUrl: pdfUrl);
  }
}
