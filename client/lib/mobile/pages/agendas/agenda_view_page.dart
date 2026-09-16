import 'package:flutter/material.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/view_models/agenda_view_model.dart';
import 'package:qfqq/common/widgets/agendas/meeting_view_content.dart';
import 'package:qfqq/common/widgets/agendas/meeting_view_control.dart';
import 'package:qfqq/common/widgets/details_attribute_widget.dart';
import 'package:qfqq/common/widgets/details_list_widget.dart';
import 'package:qfqq/common/widgets/projects/project_title_link_widget.dart';
import 'package:qfqq/common/utils/fromatting.dart';
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

class _AgendaViewPage extends StatefulWidget {
  final AgendaViewPageViewModelState vm;

  const _AgendaViewPage({required this.vm});

  @override
  State<_AgendaViewPage> createState() => _AgendaViewPageState();
}

enum _MeetingTab { info, decisions }

class _AgendaViewPageState extends State<_AgendaViewPage> {
  _MeetingTab _tab = _MeetingTab.decisions;

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final agenda = widget.vm.agenda;

    if (agenda == null) {
      return Center(child: Text(loc.meetingNotFound));
    }

    final isOngoing = agenda.status == MeetingAgendaStatus.ongoing;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopCard(context, agenda, isOngoing),
          const SizedBox(height: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isOngoing || _tab == _MeetingTab.info)
                  Flexible(fit: FlexFit.loose, child: _buildDetails(context, loc, agenda)),
                if (!isOngoing || _tab == _MeetingTab.decisions)
                  Expanded(child: MeetingViewContent(meeting: agenda)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(child: MeetingViewControl(meeting: agenda)),
        ],
      ),
    );
  }

  Widget _buildTopCard(BuildContext context, MeetingAgenda agenda, bool isOngoing) {
    final statusUIData = getMeetingAgendaStatusUI(S.of(context), agenda.status);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: TitleWithStatus(
            title: '${agenda.number}: ${agenda.title}',
            uiData: statusUIData,
          )
        ),

        if (widget.vm.hasProject)
          ProjectTitleLinkWidget(projectId: widget.vm.projectId, minimized: true),

        if (isOngoing)
          IconButton(
            onPressed: () => setState(() => _tab = _tab == _MeetingTab.decisions
                ? _MeetingTab.info
                : _MeetingTab.decisions),
            icon: Icon(
              _tab == _MeetingTab.decisions
                  ? Icons.info_outline
                  : Icons.edit_note,
              size: 22,
            ),
            visualDensity: VisualDensity.compact,
          ),
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
            label: loc.attributeLocationDate,
            value:
                '${agenda.meetingLocation ?? loc.commonNoLocationSet} • '
                '${agenda.meetingDate != null ? formatDate(context, agenda.meetingDate) : loc.commonNoDateSet}',
          ),
          DetailsAttributeWidget(
            label: loc.attributeAnimator,
            value:
                widget.vm.animatorName.isNotEmpty
                    ? widget.vm.animatorName
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
            values: widget.vm.participantNames.isNotEmpty ? widget.vm.participantNames : [],
          ),
        ],
      ),
    );
  }
}
