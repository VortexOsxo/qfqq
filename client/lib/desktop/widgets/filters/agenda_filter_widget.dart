import 'package:flutter/material.dart';
import 'package:qfqq/common/view_models/agenda_list_page_view_model.dart';
import 'package:qfqq/common/widgets/dropdowns/agenda_status_dropdown_menu.dart';
import 'package:qfqq/common/widgets/dropdowns/project_dropdown_menu.dart';
import 'package:qfqq/common/widgets/reusables/default_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

class AgendaFilterWidget extends StatelessWidget {
  final AgendaListPageViewModelState vm;

  const AgendaFilterWidget({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DefaultTextField(
          onChanged: vm.onSearchQueryChanged,
          hintText: S.of(context).searchTitleIdHint,
        ),
        SizedBox(height: 8),
        Row(
          children: [
            AgendaStatusDropdownMenu(
              initialStatus: vm.statusQuery,
              valueChanged: vm.onStatusQueryChanged,
            ),
            SizedBox(width: 16),
            ProjectDropdownMenu(
              initialProject: vm.projectIdQuery,
              valueChanged: vm.onProjectQueryChanged,
            ),
          ],
        ),
      ],
    );
  }
}
