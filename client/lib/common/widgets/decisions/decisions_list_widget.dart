import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/providers/decisions_provider.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/templates/card_template.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/common/utils/is_id_valid.dart';
import 'package:qfqq/common/widgets/default_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

class DecisionsListWidget extends ConsumerStatefulWidget {
  final bool refetch;
  final bool isProjectFilterEnabled;

  final bool Function(Decision)? filterFunction;

  const DecisionsListWidget({
    super.key,
    this.refetch = true,
    this.isProjectFilterEnabled = true,
    this.filterFunction,
  });

  @override
  ConsumerState<DecisionsListWidget> createState() => _DecisionsListPageState();
}

class _DecisionsListPageState extends ConsumerState<DecisionsListWidget> {
  // Local state for filters
  String _searchQuery = '';
  int? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(decisionsFetcherProvider.notifier).loadData();
    });
  }

  List<Decision> _getFilteredDecisions() {
    var decisionsFetcher = ref.watch(decisionsFetcherProvider);

    if (!decisionsFetcher.isLoaded) return const [];
    var decisions = decisionsFetcher.data!;

    if (_searchQuery.isNotEmpty) {
      decisions =
          decisions
              .where(
                (Decision decision) => decision.description
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()),
              )
              .toList();
    }

    if (isIdValid(_selectedProjectId) && widget.isProjectFilterEnabled) {
      decisions =
          decisions
              .where((decision) => decision.projectId == _selectedProjectId)
              .toList();
    }

    if (widget.filterFunction != null) {
      decisions = decisions.where(widget.filterFunction!).toList();
    }

    return decisions;
  }

  @override
  Widget build(BuildContext context) {
    final decisions = _getFilteredDecisions();

    return Column(
      children: [
        _buildSearchAndFilterSection(context, ref),
        Expanded(child: _buildDecisionsList(context, ref, decisions)),
      ],
    );
  }

  Widget _buildSearchAndFilterSection(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultTextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            hintText: S.of(context).commonSearch,
          ),
          SizedBox(height: 8),
          if (widget.isProjectFilterEnabled)
            Row(children: [_buildProjectFilterDropdown(context, ref)]),
        ],
      ),
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
          label: '${S.of(context).commonProject}: ${project.title}',
        ),
      ),
    ]);

    return DropdownMenu<int?>(
      width: 200,
      initialSelection: _selectedProjectId,
      onSelected: (int? value) {
        setState(() {
          _selectedProjectId = value;
        });
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
            Expanded(child: Text(loc.decisionListNumber)),
            Expanded(child: Text(loc.decisionListDescription)),
            Expanded(child: Text(loc.attributeStatus)),
            Expanded(child: Text(loc.decisionListDueDate)),
            Expanded(child: Text(loc.decisionListResponsible)),
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


              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(width: 16),
                  Expanded(child: Text(decision.number.toString())),
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
                      project != null ? project.title : loc.commonNoProjectSet,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          child: Text(loc.agendaListView),
                          onPressed:
                              () => context.go('/decisions/${decision.id}'),
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
