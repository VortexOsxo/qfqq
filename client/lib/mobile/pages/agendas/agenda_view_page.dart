import 'package:flutter/material.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/models/configs/report_config.dart';
import 'package:qfqq/common/utils/is_id_valid.dart';
import 'package:qfqq/common/view_models/agenda_view_model.dart';
import 'package:qfqq/common/widgets/agenda_view_page/agenda_description_widget.dart';
import 'package:qfqq/common/widgets/agendas/meeting_agenda_session.dart';
import 'package:qfqq/common/widgets/agenda_view_page/meeting_view_content.dart';
import 'package:qfqq/common/widgets/agendas/meeting_view_control.dart';
import 'package:qfqq/common/widgets/decisions/decisions_list_widget.dart';
import 'package:qfqq/common/widgets/meeting_review_list.dart';
import 'package:qfqq/common/widgets/navigation/navigation_text_button.dart';
import 'package:qfqq/common/widgets/report_pdf_viewer.dart';
import 'package:qfqq/common/utils/get_status_ui.dart';
import 'package:qfqq/generated/l10n.dart';
import 'package:qfqq/mobile/widgets/title_with_status.dart';

class AgendaViewPage extends StatelessWidget {
  final int agendaId;
  const AgendaViewPage({super.key, required this.agendaId});

  @override
  Widget build(BuildContext context) {
    return AgendaViewModel(
      agendaId: agendaId,
      builder: (vm) => _AgendaViewPage(vm: vm),
    );
  }
}

class _AgendaViewPage extends StatelessWidget {
  final AgendaViewPageViewModelState vm;

  const _AgendaViewPage({required this.vm});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final agenda = vm.agenda;

    if (agenda == null) {
      return Center(child: Text(loc.meetingNotFound));
    }

    final isCompleted = agenda.status == MeetingAgendaStatus.completed;

    return MeetingAgendaSession(
      meetingId: agenda.id,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8,0,8,8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProjectNavigationTextLink(projectId: vm.projectId),
            SizedBox(height: 8),
            TitleWithStatus(
              title: '${agenda.number}: ${agenda.title}',
              uiData: getMeetingAgendaStatusUI(S.of(context), agenda.status),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: DefaultTabController(
                length: isCompleted ? 4 : 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      tabs: [
                        Tab(text: loc.commonObjectInfo),
                        if (isCompleted) ...[
                          Tab(text: loc.commonObjectDecisions),
                          Tab(text: loc.commonObjectReports),
                          Tab(text: loc.commonObjectReviews),
                        ] else
                          Tab(text: loc.commonObjectContent),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: TabBarView(
                        children: [
                          AgendaDescriptionWidget(vm: vm),
                          if (isCompleted) ...[
                            _buildDecisionLists(agenda),
                            ReportPdfViewer(
                              config: ReportConfig.forMeeting(agenda),
                            ),
                            MeetingReviewList(meetingId: agenda.id),
                          ] else
                            MeetingViewContent(meeting: agenda),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(child: MeetingViewControl(meeting: agenda)),
          ],
        ),
      ),
    );
  }

  Widget _buildDecisionLists(MeetingAgenda meeting) {
    bool filterFunc(decision) => isIdValidAndEqual(meeting.id, decision.meetingId);

    return DecisionsListWidget(
      isProjectFilterEnabled: false,
      filterFunction: filterFunc,
    );
  }
}
