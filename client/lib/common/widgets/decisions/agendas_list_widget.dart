import 'package:flutter/material.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/templates/card_template.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/common/utils/get_status_ui.dart';
import 'package:qfqq/common/utils/text.dart';
import 'package:qfqq/common/widgets/empty_list_widget.dart';
import 'package:qfqq/common/widgets/icon_status_chip.dart';
import 'package:qfqq/common/widgets/projects/project_clickable_text_widget.dart';
import 'package:qfqq/common/widgets/status_chip.dart';
import 'package:qfqq/generated/l10n.dart';

class AgendasListWidget extends StatelessWidget {
  final List<MeetingAgenda> agendas;
  final String Function(int? animatorId, String fallback) animatorName;
  final void Function(int agendaId) goToAgenda;
  final bool showDetails;

  const AgendasListWidget({
    super.key,
    required this.agendas,
    required this.animatorName,
    required this.goToAgenda,
    this.showDetails = true,
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
            SizedBox(width: showDetails ? 16 : 8),
            Expanded(flex: 1, child: Text(S.of(context).attributeNumber)),
            Expanded(flex: 3, child: Text(S.of(context).agendaListTitle)),

            Expanded(flex: 3, child: Text(S.of(context).agendaListDate)),
            if (showDetails) Expanded(flex: 3, child: Text(S.of(context).agendaListLocation)),
            if (showDetails) Expanded(flex: 3, child: Text(S.of(context).agendaListAnimator)),
            if (showDetails) Expanded(flex: 3, child: Text(S.of(context).agendaListProject)),
            if (showDetails) ...[
              Expanded(flex: 3, child: Center(child: Text(S.of(context).attributeStatus))),
              Expanded(flex: 2, child: Center(child: Text(S.of(context).commonAction))),
            ] else 
              Expanded(flex:2, child: SizedBox()),
            SizedBox(width: showDetails ? 16 : 8),
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
              final uiData = getMeetingAgendaStatusUI(loc, agenda.status);

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(width: showDetails ? 16 : 8),
                  Expanded(flex: 1, child: Text(agenda.number.toString())),
                  Expanded(flex: 3, child: listText(agenda.title)),
                  Expanded(
                    flex: 3,
                    child: Text(
                      agenda.meetingDate != null
                          ? formatDate(context, agenda.meetingDate)
                          : loc.commonNoDateSet,
                    ),
                  ),
                  if (showDetails) Expanded(
                    flex: 3,
                    child: Text(
                      agenda.meetingLocation ?? loc.commonNoLocationSet,
                    ),
                  ),
                  if (showDetails) Expanded(
                    flex: 3,
                    child: listText(
                      animatorName(
                        agenda.animatorId,
                        loc.commonNoAnimatorSet,
                      ),
                    ),
                  ),
                  if (showDetails) Expanded(
                    flex: 3,
                    child: ProjectClickableTextWidget(
                      projectId: agenda.projectId,
                    ),
                  ),
                  if (showDetails) ..._desktopOther(context, loc, agenda, uiData)
                  else ..._mobileOther(context, loc, agenda, uiData),

                  SizedBox(width: showDetails ? 16 : 8),
                ],
              );
            },
          ),
        ),
      ],
    );
    return buildContentListCardTemplate(cardContent);
  }


  List<Widget> _mobileOther(context, loc, agenda, uiData) {
    return [
      Expanded(
        flex: 2,
        child: Row(
          children: [
            Center(child: IconStatusChip(statusUIData: uiData)),
            TextButton(
              style: inplaceTextButtonStyle(context),
              onPressed: () => goToAgenda(agenda.id),
              child: Text(loc.agendaListView),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _desktopOther(context, loc, agenda, uiData) {
    return [
      Expanded(
        flex: 3,
        child: StatusChip(statusUIData: uiData, alignement: Alignment.center),
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
    ];
  }
}
