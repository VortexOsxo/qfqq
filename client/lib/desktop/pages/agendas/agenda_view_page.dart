import 'package:flutter/material.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/view_models/agenda_view_model.dart';
import 'package:qfqq/common/widgets/agenda_view_page/agenda_description_widget.dart';
import 'package:qfqq/common/widgets/agendas/meeting_agenda_session.dart';
import 'package:qfqq/common/widgets/agenda_view_page/meeting_view_content.dart';
import 'package:qfqq/common/widgets/agendas/meeting_view_control.dart';
import 'package:qfqq/common/widgets/projects/project_title_link_widget.dart';
import 'package:qfqq/generated/l10n.dart';

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

    return MeetingAgendaSession(
      meetingId: agenda.id,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            _buildTopCard(context, agenda),
            const SizedBox(height: 16),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: SizedBox(
                      width: 250,
                      child: _buildMeetingInfo(context, agenda),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(child: MeetingViewContent(meeting: agenda)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCard(BuildContext context, MeetingAgenda agenda) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${agenda.number}: ${agenda.title}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: theme.primaryColor,
            ),
          ),

          if (vm.hasProject)
            ProjectTitleLinkWidget(projectId: vm.projectId),
        ],
      ),
    );
  }

  Widget _buildMeetingInfo(BuildContext context, MeetingAgenda agenda) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: AgendaDescriptionWidget(vm: vm)),
        const SizedBox(height: 16),
        Center(child: MeetingViewControl(meeting: agenda)),
      ],
    );
  }
}
