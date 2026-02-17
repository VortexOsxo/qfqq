import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/templates/card_template.dart';
import 'package:qfqq/common/templates/page_template.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/common/utils/get_status_ui.dart';
import 'package:qfqq/common/utils/is_id_valid.dart';
import 'package:qfqq/common/widgets/agendas/meeting_status_chip.dart';
import 'package:qfqq/common/widgets/default_text_field.dart';
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
  if (isIdValid(projectId)) {
    agendas = agendas.where((agenda) => agenda.projectId == projectId).toList();
  }

  return agendas;
});

class AgendasListPage extends ConsumerWidget {
  const AgendasListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agendas = ref.watch(filteredAgendaProvider);

    String title = S.of(context).agendasListPageTitle;
    Widget content = Column(
      children: [
        _buildSearchAndFilterSection(context, ref),
        Expanded(child: _buildAgendasList(context, ref, agendas)),
      ],
    );
    return buildPageTemplate(context, content, title);
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
    return DropdownMenu<MeetingAgendaStatus?>(
      width: 200,
      initialSelection: ref.read(agendaStatusQueryProvider),
      onSelected: (MeetingAgendaStatus? value) {
        ref.read(agendaStatusQueryProvider.notifier).state = value;
      },
      dropdownMenuEntries: menuEntries,
    );
  }

  Widget _buildProjectFilterDropdown(BuildContext context, WidgetRef ref) {
    var projects = ref.watch(projectsProvider);

    final List<DropdownMenuEntry<int?>> menuEntries = UnmodifiableListView([
      DropdownMenuEntry<int?>(
        value: null,
        label: S.of(context).agendaListAnyProject,
      ),
      ...projects.map(
        (project) => DropdownMenuEntry<int?>(
          value: project.id,
          label: 'Project: ${project.title}',
        ),
      ),
    ]);
    return DropdownMenu<int?>(
      width: 200,
      initialSelection: ref.read(agendaProjectQueryProvider),
      onSelected: (int? value) {
        ref.read(agendaProjectQueryProvider.notifier).state = value;
      },
      dropdownMenuEntries: menuEntries,
    );
  }

  Widget _buildAgendasList(
    BuildContext context,
    WidgetRef ref,
    List<MeetingAgenda> agendas,
  ) {
    if (agendas.isEmpty) {
      Widget cardContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.list_alt, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              S.of(context).agendasListPageEmpty,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
      return buildContentListCardTemplate(cardContent);
    }

    void startMeeting(agenda) async {
      final meetingsService = ref.read(meetingAgendaServiceProvider);

      await meetingsService.updateMeetingAgendaStatus(
        agenda.id,
        MeetingAgendaStatus.ongoing,
      );
      if (context.mounted) {
        context.go('/agendas/${agenda.id}');
      }
    }

    Widget cardContent = Column(
      children: [
        Row(
          children: [
            SizedBox(width: 16),
            Expanded(child: Text(S.of(context).agendaListNumber)),
            Expanded(child: Text(S.of(context).agendaListTitle)),
            Expanded(child: Text(S.of(context).attributeStatus)),
            Expanded(child: Text(S.of(context).agendaListDate)),
            Expanded(child: Text(S.of(context).agendaListLocation)),
            Expanded(child: Text(S.of(context).agendaListAnimator)),
            Expanded(child: Text(S.of(context).agendaListProject)),
            Expanded(
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
              final project =
                  isIdValid(agenda.projectId)
                      ? ref.watch(projectProviderById(agenda.projectId!))
                      : null;
              final animator =
                  isIdValid(agenda.animatorId)
                      ? ref.watch(userByIdProvider(agenda.animatorId!))
                      : null;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(width: 16),
                  Expanded(child: Text(agenda.number.toString())),
                  Expanded(child: Text(agenda.title)),
                  Expanded(child: MeetingStatusChip(status: agenda.status)),
                  Expanded(
                    child: Text(
                      agenda.meetingDate != null
                          ? formatDate(context, agenda.meetingDate)
                          : loc.commonNoDateSet,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      agenda.meetingLocation ?? loc.commonNoLocationSet,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      animator != null
                          ? animator.username
                          : loc.commonNoAnimatorSet,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      project != null ? project.title : loc.commonNoProjectSet,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          child: Text(loc.agendaListView),
                          onPressed: () => context.go('/agendas/${agenda.id}'),
                        ),
                        SizedBox(width: 8),
                        TextButton(
                          onPressed:
                              agenda.status != MeetingAgendaStatus.planned
                                  ? null
                                  : () => startMeeting(agenda),
                          child: Text(loc.agendaListStart),
                        ),
                      ],
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
