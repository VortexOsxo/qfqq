import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/templates/page_template.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/common/utils/is_id_valid.dart';
import 'package:qfqq/common/widgets/default_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

final agendaSearchQueryProvider = StateProvider<String>((ref) => '');
final agendaStatusQueryProvider = StateProvider<MeetingAgendaStatus?>(
  (ref) => MeetingAgendaStatus.draft,
);
final agendaProjectQueryProvider = StateProvider<String?>((ref) => null);

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
          DefaultTextField(
            onChanged:
                (value) =>
                    ref.read(agendaSearchQueryProvider.notifier).state = value,
            hintText: 'Search',
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
    final List<DropdownMenuEntry<MeetingAgendaStatus?>> menuEntries =
        UnmodifiableListView([
          const DropdownMenuEntry<MeetingAgendaStatus?>(
            value: null,
            label: 'Any Status',
          ),
          ...MeetingAgendaStatus.values.map(
            (status) => DropdownMenuEntry<MeetingAgendaStatus?>(
              value: status,
              label: 'Status: ${status.name}',
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

    final List<DropdownMenuEntry<String?>> menuEntries = UnmodifiableListView([
      const DropdownMenuEntry<String?>(
        value: null,
        label: 'Any Project',
      ),
      ...projects.map(
        (project) => DropdownMenuEntry<String?>(
          value: project.id,
          label: 'Project: ${project.title}',
        ),
      ),
    ]);
    return DropdownMenu<String?>(
      width: 200,
      initialSelection: ref.read(agendaProjectQueryProvider),
      onSelected: (String? value) {
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
    buildCard(Widget cardContent) {
      return Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.only(top: 16, bottom: 16),
          child: cardContent,
        ),
      );
    }

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
      return buildCard(cardContent);
    }

    Widget cardContent = Column(
      children: [
        Row(
          children: [
            SizedBox(width: 16),
            Expanded(child: Text('Title')),
            Expanded(child: Text('Status')),
            Expanded(child: Text('Date')),
            Expanded(child: Text('Location')),
            Expanded(child: Text('Animator')),
            Expanded(child: Text('Project')),
            Expanded(
              child: Align(alignment: Alignment.center, child: Text('Action')),
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
                  Expanded(child: Text(agenda.title)),
                  Expanded(child: _buildStatusChip(context, agenda.status)),
                  Expanded(
                    child: Text(
                      agenda.reunionDate != null
                          ? formatDate(context, agenda.reunionDate)
                          : 'No date set',
                    ),
                  ),
                  Expanded(
                    child: Text(agenda.reunionLocation ?? 'No location set'),
                  ),
                  Expanded(
                    child: Text(
                      animator != null ? animator.username : 'No animator set',
                    ),
                  ),
                  Expanded(
                    child: Text(
                      project != null ? project.title : 'No project set',
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          child: Text('View'),
                          onPressed: () => context.go('/agendas/${agenda.id}'),
                        ),
                        SizedBox(width: 8),
                        TextButton(
                          onPressed:
                              agenda.status != MeetingAgendaStatus.planned
                                  ? null
                                  : () => context.go(
                                    '/meeting-in-progress/${agenda.id}',
                                  ),
                          child: Text('Start'),
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
    return buildCard(cardContent);
  }

  Widget _buildStatusChip(BuildContext context, MeetingAgendaStatus status) {
    Color color;
    String label;

    switch (status) {
      case MeetingAgendaStatus.draft:
        color = Colors.orange;
        label = S.of(context).agendaStatusDraft;
        break;
      case MeetingAgendaStatus.planned:
        color = Colors.blue;
        label = S.of(context).agendaStatusPlanned;
        break;
      case MeetingAgendaStatus.completed:
        color = Colors.green;
        label = S.of(context).agendaStatusCompleted;
        break;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
