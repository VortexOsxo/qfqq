import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/templates/button_template.dart';
import 'package:qfqq/common/templates/page_template.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/common/utils/is_id_valid.dart';
import 'package:qfqq/common/widgets/pdf_viewer_widget.dart';
import 'package:qfqq/generated/l10n.dart';

class AgendaViewPage extends ConsumerWidget {
  final int agendaId;
  const AgendaViewPage({super.key, required this.agendaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);
    String title = loc.agendaPageTitleAppBar;

    MeetingAgenda? agenda = ref.watch(meetingAgendaByIdProvider(agendaId));
    return buildPageTemplate(
      context,
      _buildContent(context, ref, agenda),
      title,
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    MeetingAgenda? agenda,
  ) {
    final loc = S.of(context);
    if (agenda == null) {
      return Center(
        child: Text(loc.projectNotFound),
      ); // TODO: meetingAgendaNotFound
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

                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildNavButtonTemplate(
                            context,
                            loc.commonModify,
                            '/agenda',
                            extra: agenda,
                          ),
                          buildNavButtonTemplate(
                            context,
                            loc.commonStart,
                            '/meeting-in-progress/${agenda.id}',
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Expanded(child: _buildReportViewer(context)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportViewer(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);

    final pdfUrl =
        'http://localhost:5000/meeting-agendas/$agendaId/reports?lang=${locale.languageCode}';

    return PdfViewerWidget(pdfUrl: pdfUrl);
  }

  Widget _buildTopCard(
    BuildContext context,
    WidgetRef ref,
    MeetingAgenda agenda,
  ) {
    final loc = S.of(context);
    Project? project =
        isIdValid(agenda.projectId)
            ? ref.watch(projectProviderById(agenda.projectId!))
            : null;

    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            agenda.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: theme.primaryColor,
            ),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${loc.commonProject}: ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                project?.title ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: () => context.go('/project/${agenda.projectId}'),
                icon: Icon(
                  Icons.open_in_new,
                  size: 24,
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingInfo(
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
          _detailText('${loc.attributeGoals}: '),
          Text(agenda.goals ?? loc.commonNoGoalsSet),
          const SizedBox(height: 8),
          _detailText('${loc.attributeLocation}: '),
          Text(agenda.meetingLocation ?? loc.commonNoDateSet),
          const SizedBox(height: 8),
          _detailText('${loc.attributeDate}: '),
          Text(
            agenda.meetingDate != null
                ? formatDate(context, agenda.meetingDate)
                : loc.commonNoDateSet,
          ),
          const SizedBox(height: 8),
          _detailText('${loc.attributeAnimator}: '),
          Text(animator?.username ?? loc.commonNoAnimatorSet),
          const SizedBox(height: 8),
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
      children: agenda.themes
          .map((theme) => Text('• $theme'))
          .toList(),
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
      children: agenda.participantsIds
          .map((participantId) {
              final participant = ref.watch(userByIdProvider(participantId));
              return Text('• ${participant?.username ?? loc.commonUnknown}');
          }).toList(),
    );
  }
}
