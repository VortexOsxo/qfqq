import 'package:flutter/material.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/view_models/agenda_list_page_view_model.dart';
import 'package:qfqq/common/widgets/decisions/agendas_list_widget.dart';
import 'package:qfqq/common/widgets/dropdowns/agenda_status_dropdown_menu.dart';
import 'package:qfqq/common/widgets/dropdowns/project_dropdown_menu.dart';
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
        Expanded(
          child: AgendasListWidget(
            agendas: agendas,
            animatorName: vm.animatorName,
            goToAgenda: vm.goToAgenda,
          ),
        ),
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
      ),
    );
  }
}
