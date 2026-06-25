import 'package:flutter/material.dart';
import 'package:qfqq/common/view_models/agenda_list_page_view_model.dart';
import 'package:qfqq/common/widgets/dropdowns/agenda_status_dropdown_menu.dart';
import 'package:qfqq/common/widgets/dropdowns/project_dropdown_menu.dart';
import 'package:qfqq/common/widgets/reusables/default_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

class AgendaFilterWidget extends StatefulWidget {
  final AgendaListPageViewModelState vm;

  const AgendaFilterWidget({super.key, required this.vm});

  @override
  State<StatefulWidget> createState() => _AgendaFilterWidgetState();
}

class _AgendaFilterWidgetState extends State<AgendaFilterWidget> {
  bool isExpanded = false;

  AgendaListPageViewModelState get vm => widget.vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultTextField(
          onChanged: vm.onSearchQueryChanged,
          hintText: S.of(context).searchTitleIdHint,
        ),
        _buildToggle(context),
        if (isExpanded) ...[
          const SizedBox(height: 8),
          AgendaStatusDropdownMenu(
            initialStatus: vm.statusQuery,
            valueChanged: vm.onStatusQueryChanged,
          ),
          const SizedBox(height: 8),
          ProjectDropdownMenu(
            initialProject: vm.projectIdQuery,
            valueChanged: vm.onProjectQueryChanged,
          ),
        ],
      ],
    );
  }

  Widget _buildToggle(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      child: Row(
        children: [
          Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: theme.colorScheme.primary,
          ),
          Text(
            S.of(context).toggleAdvancedFilters,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      onTap: () => setState(() => isExpanded = !isExpanded),
    );
  }
}
