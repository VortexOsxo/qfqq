import 'package:flutter/material.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/templates/card_template.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/common/utils/get_status_ui.dart';
import 'package:qfqq/common/widgets/empty_list_widget.dart';
import 'package:qfqq/common/widgets/projects/project_clickable_text_widget.dart';
import 'package:qfqq/common/widgets/status_chip.dart';
import 'package:qfqq/generated/l10n.dart';

class AgendasListWidget extends StatelessWidget {
  final List<MeetingAgenda> agendas;
  final String Function(int? animatorId, String fallback) animatorName;
  final void Function(int agendaId) goToAgenda;

  const AgendasListWidget({
    super.key,
    required this.agendas,
    required this.animatorName,
    required this.goToAgenda,
  });

  @override
  Widget build(BuildContext context) {
    if (agendas.isEmpty) {
      Widget cardContent = EmptyListWidget(
        text: S.of(context).agendasListPageEmpty,
      );
      return buildContentListCardTemplate(cardContent);
    }

    Widget cardContent = Column(
      children: [
        Row(
          children: [
            SizedBox(width: 16),
            Expanded(flex: 1, child: Text(S.of(context).attributeNumber)),
            Expanded(flex: 3, child: Text(S.of(context).agendaListTitle)),
            Expanded(flex: 3, child: Text(S.of(context).attributeStatus)),
            Expanded(flex: 3, child: Text(S.of(context).agendaListDate)),
            Expanded(flex: 3, child: Text(S.of(context).agendaListLocation)),
            Expanded(flex: 3, child: Text(S.of(context).agendaListAnimator)),
            Expanded(flex: 3, child: Text(S.of(context).agendaListProject)),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.center,
                child: Text(S.of(context).commonAction),
              ),
            ),
            SizedBox(width: 16),
          ],
        ),
        Divider(color: Theme.of(context).colorScheme.primary, thickness: 2),
        Expanded(
          child: ListView.separated(
            itemCount: agendas.length,
            separatorBuilder:
                (BuildContext context, int index) => const Divider(),
            itemBuilder: (context, index) {
              final loc = S.of(context);
              final agenda = agendas[index];

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(width: 16),
                  Expanded(flex: 1, child: Text(agenda.number.toString())),
                  Expanded(flex: 3, child: Text(agenda.title)),
                  Expanded(
                    flex: 3,
                    child: StatusChip(statusUIData: getMeetingAgendaStatusUI(S.of(context), agenda.status)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      agenda.meetingDate != null
                          ? formatDate(context, agenda.meetingDate)
                          : loc.commonNoDateSet,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      agenda.meetingLocation ?? loc.commonNoLocationSet,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      animatorName(
                        agenda.animatorId,
                        loc.commonNoAnimatorSet,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ProjectClickableTextWidget(
                      projectId: agenda.projectId,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        style: inplaceTextButtonStyle(context),
                        onPressed: () => goToAgenda(agenda.id),
                        child: Text(loc.agendaListView),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                ],
              );
            },
          ),
        ),
      ],
    );
    return buildContentListCardTemplate(cardContent);
  }

}
