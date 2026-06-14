import 'package:flutter/material.dart';
import 'package:qfqq/common/view_models/agenda_list_page_view_model.dart';
import 'package:qfqq/common/widgets/agendas/agenda_filter_widget.dart';
import 'package:qfqq/common/widgets/decisions/agendas_list_widget.dart';

class AgendasListPage extends StatelessWidget {
  const AgendasListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AgendaListPageViewModel(builder: (vm) => _AgendaPageView(vm: vm));
  }
}

class _AgendaPageView extends StatelessWidget {
  final AgendaListPageViewModelState vm;

  const _AgendaPageView({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
          child: AgendaFilterWidget(vm: vm),
        ),
        Expanded(
          child: AgendasListWidget(
            agendas: vm.filteredAgendas,
            animatorName: vm.animatorName,
            goToAgenda: vm.goToAgenda,
          ),
        ),
      ],
    );
  }
}
