import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/templates/card_template.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/common/utils/get_status_ui.dart';
import 'package:qfqq/common/view_models/agenda_list_page_view_model.dart';
import 'package:qfqq/common/widgets/status_chip.dart';
import 'package:qfqq/common/widgets/empty_list_widget.dart';
import 'package:qfqq/common/widgets/projects/project_clickable_text_widget.dart';
import 'package:qfqq/common/widgets/reusables/default_dropdown_menu.dart';
import 'package:qfqq/common/widgets/reusables/default_text_field.dart';
import 'package:qfqq/generated/l10n.dart';


class AgendasListPage extends StatelessWidget {
  const AgendasListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AgendaListPageViewModel(
      builder: (vm) => _AgendaPageView(vm: vm)
    );
  }
}

class _AgendaPageView extends StatelessWidget {
  final AgendaListPageViewModelState vm;

  const _AgendaPageView({required this.vm});


  @override
  Widget build(BuildContext context) {
    final agendas = vm.filteredAgendas;

    return Column(
      children: [
        _buildSearchAndFilterSection(context),
        Expanded(child: _buildAgendasList(context, agendas)),
      ],
    );
  }

  Widget _buildSearchAndFilterSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 6,
                child: DefaultTextField(
                  onChanged: vm.onSearchQueryChanged,
                  hintText: S.of(context).searchTitleIdHint,
                ),
              ),
              Expanded(flex: 1, child: SizedBox()),
              ElevatedButton(
                onPressed: vm.goToAgendaCreation,
                style: squareButtonStyle(context),
                child: Text(S.of(context).buttonCreateAgenda),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              _buildStatusFilterDropdown(context),
              SizedBox(width: 16),
              _buildProjectFilterDropdown(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterDropdown(BuildContext context) {
    String getStatusLabel(MeetingAgendaStatus status) {
      var loc = S.of(context);
      var ui = getMeetingAgendaStatusUI(loc, status);
      return '${loc.attributeStatus}: ${ui.label}';
    }

    final List<DropdownMenuEntry<MeetingAgendaStatus?>> menuEntries =
        UnmodifiableListView([
          DropdownMenuEntry<MeetingAgendaStatus?>(
            value: null,
            label: S.of(context).agendaListAnyStatus,
          ),
          ...MeetingAgendaStatus.values.map(
            (status) => DropdownMenuEntry<MeetingAgendaStatus?>(
              value: status,
              label: getStatusLabel(status),
            ),
          ),
        ]);

    return DefaultDropdownMenu<MeetingAgendaStatus?>(
      entries: menuEntries,
      initialSelection: vm.statusQuery,
      onSelected: vm.onStatusQueryChanged,
    );
  }

  Widget _buildProjectFilterDropdown(BuildContext context) {
    var projects = vm.projects;

    final List<DropdownMenuEntry<int?>> menuEntries = UnmodifiableListView([
      DropdownMenuEntry<int?>(
        value: null,
        label: S.of(context).agendaListAnyProject,
      ),
      DropdownMenuEntry<int?>(
        value: -1,
        label: S.of(context).agendaListNoProject,
      ),

      ...projects.map(
        (project) => DropdownMenuEntry<int?>(
          value: project.id,
          label: '${S.of(context).attributeProject}: ${project.title}',
        ),
      ),
    ]);
    return DefaultDropdownMenu<int?>(
      entries: menuEntries,
      initialSelection: vm.projectIdQuery,
      onSelected: vm.onProjectQueryChanged,
    );
  }

  Widget _buildAgendasList(BuildContext context, List<MeetingAgenda> agendas) {
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
                      vm.animatorName(
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
                        onPressed: () => vm.goToAgenda(agenda.id),
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
