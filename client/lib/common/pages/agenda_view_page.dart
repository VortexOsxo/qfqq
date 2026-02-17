import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/common/widgets/agendas/meeting_status_chip.dart';
import 'package:qfqq/common/widgets/agendas/meeting_view_content.dart';
import 'package:qfqq/common/widgets/agendas/meeting_view_control.dart';
import 'package:qfqq/common/widgets/details_attribute_widget.dart';
import 'package:qfqq/common/widgets/projects/project_title_link_widget.dart';
import 'package:qfqq/generated/l10n.dart';

class AgendaViewPage extends ConsumerWidget {
  final int agendaId;
  const AgendaViewPage({super.key, required this.agendaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    MeetingAgenda? agenda = ref.watch(meetingAgendaByIdProvider(agendaId));
    return _buildContent(context, ref, agenda);
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    MeetingAgenda? agenda,
  ) {
    final loc = S.of(context);
    if (agenda == null) {
      return Center(child: Text(loc.meetingNotFound));
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          _buildTopCard(context, ref, agenda),

          const SizedBox(height: 16),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: SizedBox(
                    width: 150,
                    child: _buildMeetingInfo(context, ref, agenda),
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

  Widget _buildTopCard(
    BuildContext context,
    WidgetRef ref,
    MeetingAgenda agenda,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                agenda.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: theme.primaryColor,
                ),
              ),
              SizedBox(width: 16),
              MeetingStatusChip(status: agenda.status),
            ],
          ),

          ProjectTitleLinkWidget(projectId: agenda.projectId ?? 0),
        ],
      ),
    );
  }

  Widget _buildMeetingInfo(
    BuildContext context,
    WidgetRef ref,
    MeetingAgenda agenda,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: _buildDetails(context, ref, agenda)),
        const SizedBox(height: 16),
        Center(child: MeetingViewControl(meeting: agenda)),
      ],
    );
  }

  Widget _buildDetails(
    BuildContext context,
    WidgetRef ref,
    MeetingAgenda agenda,
  ) {
    final loc = S.of(context);

    final animator =
        agenda.animatorId != null
            ? ref.watch(userByIdProvider(agenda.animatorId!))
            : null;

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
            value: agenda.meetingLocation ?? loc.commonNoDateSet,
          ),
          DetailsAttributeWidget(
            label: loc.attributeDate,
            value:
                agenda.meetingDate != null
                    ? formatDate(context, agenda.meetingDate)
                    : loc.commonNoDateSet,
          ),
          DetailsAttributeWidget(
            label: loc.attributeAnimator,
            value: animator?.username ?? loc.commonNoAnimatorSet,
          ),
          _detailText('${loc.attributeThemes}: '),
          _buildThemes(context, agenda),
          const SizedBox(height: 8),
          _detailText('${loc.attributeParticipants}: '),
          _buildParticipants(context, ref, agenda),
        ],
      ),
    );
  }

  Widget _detailText(String text) {
    return Text(text, style: TextStyle(fontWeight: FontWeight.bold));
  }

  Widget _buildThemes(BuildContext context, MeetingAgenda agenda) {
    final loc = S.of(context);
    if (agenda.themes.isEmpty) {
      return Text(loc.attributeNoThemes);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: agenda.themes.map((theme) => Text('• $theme')).toList(),
    );
  }

  Widget _buildParticipants(
    BuildContext context,
    WidgetRef ref,
    MeetingAgenda agenda,
  ) {
    final loc = S.of(context);
    if (agenda.participantsIds.isEmpty) {
      return Text(loc.attributeNoParticipants);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          agenda.participantsIds.map((participantId) {
            final participant = ref.watch(userByIdProvider(participantId));
            return Text('• ${participant?.username ?? loc.commonUnknown}');
          }).toList(),
    );
  }
}
