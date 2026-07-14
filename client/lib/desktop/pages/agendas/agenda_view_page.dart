import 'package:flutter/material.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/view_models/agenda_view_model.dart';
import 'package:qfqq/common/widgets/status_chip.dart';
import 'package:qfqq/common/widgets/agendas/meeting_view_content.dart';
import 'package:qfqq/common/widgets/agendas/meeting_view_control.dart';
import 'package:qfqq/common/widgets/details_attribute_widget.dart';
import 'package:qfqq/common/widgets/details_list_widget.dart';
import 'package:qfqq/common/widgets/projects/project_title_link_widget.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/common/utils/get_status_ui.dart';
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

    return Padding(
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
    final loc = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        StatusChip(statusUIData: getMeetingAgendaStatusUI(loc, agenda.status)),
        Flexible(child: _buildDetails(context, loc, agenda)),
        const SizedBox(height: 16),
        Center(child: MeetingViewControl(meeting: agenda)),
      ],
    );
  }

  Widget _buildDetails(BuildContext context, S loc, MeetingAgenda agenda) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailsAttributeWidget(
            label: loc.attributeGoals,
            value: agenda.goals ?? loc.commonNoGoalsSet,
          ),
          DetailsAttributeWidget(
            label: loc.attributeLocation,
            value: agenda.meetingLocation ?? loc.commonNoLocationSet,
          ),
          DetailsAttributeWidget(
            label: loc.attributeDate,
            value: agenda.meetingDate != null
                ? formatDate(context, agenda.meetingDate)
                : loc.commonNoDateSet,
          ),
          DetailsAttributeWidget(
            label: loc.attributeAnimator,
            value: vm.animatorName.isNotEmpty
                ? vm.animatorName
                : loc.commonNoAnimatorSet,
          ),
          DetailsListWidget(
            label: loc.attributeThemes,
            emptyLabel: loc.attributeNoThemes,
            values: agenda.themes,
          ),
          const SizedBox(height: 8),
          DetailsListWidget(
            label: loc.attributeParticipants,
            emptyLabel: loc.attributeNoParticipants,
            values: vm.participantNames.isNotEmpty
                ? vm.participantNames
                : [],
          ),
        ],
      ),
    );
  }
}
