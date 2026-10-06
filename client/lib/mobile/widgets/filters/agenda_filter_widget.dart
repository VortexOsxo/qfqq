import 'package:flutter/material.dart';
import 'package:qfqq/common/view_models/agenda_list_page_view_model.dart';
import 'package:qfqq/common/widgets/dropdowns/agenda_status_dropdown_menu.dart';
import 'package:qfqq/common/widgets/dropdowns/project_dropdown_menu.dart';
import 'package:qfqq/common/widgets/reusables/default_text_field.dart';
import 'package:qfqq/generated/l10n.dart';
import 'package:qfqq/mobile/widgets/filters/filter_container.dart';

class AgendaFilterWidget extends StatelessWidget {
  final AgendaListPageViewModelState vm;

  const AgendaFilterWidget({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final filters = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultTextField(
          onChanged: vm.onSearchQueryChanged,
          hintText: S.of(context).searchTitleIdHint,
        ),
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
    );

    return FilterContainer(child: filters);
  }
}
