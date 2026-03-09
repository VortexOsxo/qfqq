import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/templates/card_template.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/common/utils/get_status_ui.dart';
import 'package:qfqq/common/utils/is_id_valid.dart';
import 'package:qfqq/common/widgets/status_chip.dart';
import 'package:qfqq/common/widgets/empty_list_widget.dart';
import 'package:qfqq/common/widgets/projects/project_clickable_text_widget.dart';
import 'package:qfqq/common/widgets/reusables/default_dropdown_menu.dart';
import 'package:qfqq/common/widgets/reusables/default_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

final agendaSearchQueryProvider = StateProvider<String>((ref) => '');
final agendaStatusQueryProvider = StateProvider<MeetingAgendaStatus?>(
  (ref) => null,
);
final agendaProjectQueryProvider = StateProvider<int?>((ref) => null);

final filteredAgendaProvider = Provider<List<MeetingAgenda>>((ref) {
  var agendas = ref.watch(meetingsAgendasProvider);

  final query = ref.watch(agendaSearchQueryProvider);
  if (query.isNotEmpty) {
    agendas =
        agendas
            .where(
              (MeetingAgenda agenda) =>
                  agenda.title.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
  }

  final status = ref.watch(agendaStatusQueryProvider);
  if (status != null) {
    agendas =
        agendas
            .where((MeetingAgenda agenda) => agenda.status == status)
            .toList();
  }

  final projectId = ref.watch(agendaProjectQueryProvider);
  if (projectId == -1) {
    agendas = agendas.where((agenda) => !isIdValid(agenda.projectId)).toList();
  }
  else if (isIdValid(projectId)) {
    agendas = agendas.where((agenda) => agenda.projectId == projectId).toList();
  }

  return agendas;
});

class AgendasListPage extends ConsumerWidget {
  const AgendasListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agendas = ref.watch(filteredAgendaProvider);

    return Column(
      children: [
        _buildSearchAndFilterSection(context, ref),
        Expanded(child: _buildAgendasList(context, ref, agendas)),
      ],
    );
  }

  Widget _buildSearchAndFilterSection(BuildContext context, WidgetRef ref) {
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
                  onChanged:
                      (value) =>
                          ref.read(agendaSearchQueryProvider.notifier).state =
                              value,
                  hintText: S.of(context).commonSearch,
                ),
              ),
              Expanded(flex: 1, child: SizedBox()),
              ElevatedButton(
                onPressed: () => context.go('/agenda'),
                style: squareButtonStyle(context),
                child: Text(S.of(context).buttonCreateAgenda),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              _buildStatusFilterDropdown(context, ref),
              SizedBox(width: 16),
              _buildProjectFilterDropdown(context, ref),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterDropdown(BuildContext context, WidgetRef ref) {
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
      initialSelection: ref.read(agendaStatusQueryProvider),
      onSelected: (MeetingAgendaStatus? value) {
        ref.read(agendaStatusQueryProvider.notifier).state = value;
      },
    );
  }

  Widget _buildProjectFilterDropdown(BuildContext context, WidgetRef ref) {
    var projects = ref.watch(projectsProvider);

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
      initialSelection: ref.read(agendaProjectQueryProvider),
      onSelected: (int? value) {
        ref.read(agendaProjectQueryProvider.notifier).state = value;
      },
    );
  }

  Widget _buildAgendasList(
    BuildContext context,
    WidgetRef ref,
    List<MeetingAgenda> agendas,
  ) {
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
        const Divider(),
        Expanded(
          child: ListView.separated(
            itemCount: agendas.length,
            separatorBuilder:
                (BuildContext context, int index) => const Divider(),
            itemBuilder: (context, index) {
              final loc = S.of(context);
              final agenda = agendas[index];
              final animator =
                  isIdValid(agenda.animatorId)
                      ? ref.watch(userByIdProvider(agenda.animatorId!))
                      : null;

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
                      animator != null
                          ? animator.username
                          : loc.commonNoAnimatorSet,
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
                        child: Text(loc.agendaListView),
                        onPressed: () => context.go('/agendas/${agenda.id}'),
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
