import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/templates/button_template.dart';
import 'package:qfqq/common/templates/page_template.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/common/utils/is_id_valid.dart';
import 'package:qfqq/generated/l10n.dart';

class AgendaViewPage extends ConsumerWidget {
  final String agendaId;
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
      return Center(child: Text(loc.projectNotFound));
    }

    return Center(
      child: Column(
        children: [
          _buildTopCard(context, ref, agenda),
          Padding(
            padding: EdgeInsets.all(8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(loc.agendaViewGoals(agenda.reunionGoals)),
            ),
          ),
          Spacer(),
          Center(
            child: Row(
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
    final loc = S.of(context);
    Project? project =
        isIdValid(agenda.projectId)
            ? ref.watch(projectProviderById(agenda.projectId!))
            : null;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(agenda.reunionLocation ?? loc.commonNoLocationSet),
                Text(
                  agenda.reunionDate != null
                      ? formatDate(context, agenda.reunionDate)
                      : loc.commonNoDateSet,
                ),
              ],
            ),
            Text(
              agenda.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            Text(
              project != null
                  ? loc.commonProjectWithTitle(project.title)
                  : loc.commonNoProject,
            ),
          ],
        ),
      ),
    );
  }
}
