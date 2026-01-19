import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/providers/decisions_provider.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/templates/card_template.dart';
import 'package:qfqq/common/templates/page_template.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/common/utils/is_id_valid.dart';
import 'package:qfqq/common/widgets/default_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

final decisionSearchQueryProvider = StateProvider<String>((ref) => '');
final decisionProjectQueryProvider = StateProvider<String?>((ref) => null);

final filteredDecisionProvider = Provider<List<Decision>>((ref) {
  var decisionsFetcher = ref.watch(decisionsFetcherProvider);

  if (!decisionsFetcher.isLoaded) return const [];
  var decisions = decisionsFetcher.data!;

  final query = ref.watch(decisionSearchQueryProvider);
  if (query.isNotEmpty) {
    decisions =
        decisions
            .where(
              (Decision decision) => decision.description
                  .toLowerCase()
                  .contains(query.toLowerCase()),
            )
            .toList();
  }

  final projectId = ref.watch(decisionProjectQueryProvider);
  if (isIdValid(projectId)) {
    decisions =
        decisions.where((agenda) => agenda.projectId == projectId).toList();
  }

  return decisions;
});

class DecisionsListPage extends ConsumerStatefulWidget {
  const DecisionsListPage({super.key});

  @override
  ConsumerState<DecisionsListPage> createState() => _DecisionsListPageState();
}

class _DecisionsListPageState extends ConsumerState<DecisionsListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(decisionsFetcherProvider.notifier).loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final decisions = ref.watch(filteredDecisionProvider);

    String title = S.of(context).decisionsListPageTitle;
    Widget content = Column(
      children: [
        _buildSearchAndFilterSection(context, ref),
        Expanded(child: _buildDecisionsList(context, ref, decisions)),
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
                    ref.read(decisionSearchQueryProvider.notifier).state =
                        value,
            hintText: S.of(context).commonSearch,
          ),
          SizedBox(height: 8),
          Row(children: [_buildProjectFilterDropdown(context, ref)]),
        ],
      ),
    );
  }

  Widget _buildProjectFilterDropdown(BuildContext context, WidgetRef ref) {
    var projects = ref.watch(projectsProvider);

    final List<DropdownMenuEntry<String?>> menuEntries = UnmodifiableListView([
      DropdownMenuEntry<String?>(
        value: null,
        label: S.of(context).agendaListAnyProject,
      ),
      ...projects.map(
        (project) => DropdownMenuEntry<String?>(
          value: project.id,
          label: S.of(context).commonProjectWithTitle(project.title),
        ),
      ),
    ]);
    return DropdownMenu<String?>(
      width: 200,
      initialSelection: ref.read(decisionProjectQueryProvider),
      onSelected: (String? value) {
        ref.read(decisionProjectQueryProvider.notifier).state = value;
      },
      dropdownMenuEntries: menuEntries,
    );
  }

  Widget _buildDecisionsList(
    BuildContext context,
    WidgetRef ref,
    List<Decision> decisions,
  ) {
    final loc = S.of(context);
    if (decisions.isEmpty) {
      Widget cardContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.list_alt, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              S.of(context).decisionsListPageEmpty,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
      return buildContentListCardTemplate(cardContent);
    }
    Widget cardContent = Column(
      children: [
        Row(
          children: [
            SizedBox(width: 16),
            Expanded(child: Text(loc.decisionListDescription)),
            Expanded(child: Text(loc.decisionListStatus)),
            Expanded(child: Text(loc.decisionListDueDate)),
            Expanded(child: Text(loc.decisionListResponsible)),
            Expanded(child: Text(loc.decisionListReporter)),
            Expanded(child: Text(loc.decisionListProject)),
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
            itemCount: decisions.length,
            separatorBuilder:
                (BuildContext context, int index) => const Divider(),
            itemBuilder: (context, index) {
              final loc = S.of(context);
              final decision = decisions[index];
              final project =
                  isIdValid(decision.projectId)
                      ? ref.watch(projectProviderById(decision.projectId!))
                      : null;
              final responsible =
                  isIdValid(decision.responsibleId)
                      ? ref.watch(userByIdProvider(decision.responsibleId!))
                      : null;

              final reporter =
                  isIdValid(decision.reporterId)
                      ? ref.watch(userByIdProvider(decision.reporterId!))
                      : null;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(width: 16),
                  Expanded(child: Text(decision.description)),
                  Expanded(child: Text(getDecisionStatusName(decision.status))),
                  Expanded(
                    child: Text(
                      decision.dueDate != null
                          ? formatDate(context, decision.dueDate)
                          : loc.commonNoDateSet,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      responsible != null
                          ? responsible.username
                          : loc.decisionListNoResponsibleSet,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      reporter != null
                          ? reporter.username
                          : loc.decisionListNoReporterSet,
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
                          onPressed: () => context.go('/decisions/${decision.id}'),
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
