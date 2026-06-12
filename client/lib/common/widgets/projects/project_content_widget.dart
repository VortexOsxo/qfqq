import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/utils/is_id_valid.dart';
import 'package:qfqq/common/widgets/decisions/decisions_list_widget.dart';
import 'package:qfqq/common/widgets/pdf_viewer_widget.dart';
import 'package:qfqq/generated/l10n.dart';

class ProjectContentWidget extends ConsumerWidget {
  final Project project;

  const ProjectContentWidget({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: loc.commonObjectDecisions),
              Tab(text: loc.commonObjectReports),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                buildDecisionLists(context),
                buildReportViewer(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDecisionLists(BuildContext context) {
    bool filterFunc(Decision decision) {
      if (!isIdValid(project.id)) return false;
      return decision.projectId == project.id;
    }

    return DecisionsListWidget(
      isProjectFilterEnabled: false,
      filterFunction: filterFunc,
    );
  }

  Widget buildReportViewer(BuildContext context) {
    final pdfUrl = 'reports/projects/${project.id}';
    return PdfViewerWidget(pdfUrl: pdfUrl, pdfName: project.title);
  }
}
