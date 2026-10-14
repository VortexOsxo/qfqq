import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/utils/get_status_ui.dart';
import 'package:qfqq/common/widgets/dropdowns/default_dropdown_menu.dart';
import 'package:qfqq/generated/l10n.dart';

class DecisionStatusDropdownMenu extends StatelessWidget {
  final DecisionStatus? initialStatus;
  final ValueChanged<DecisionStatus?> valueChanged;

  const DecisionStatusDropdownMenu({
    super.key,
    required this.initialStatus,
    required this.valueChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final List<DropdownMenuEntry<DecisionStatus?>> menuEntries =
        UnmodifiableListView([
          DropdownMenuEntry<DecisionStatus?>(
            value: null,
            label: loc.agendaListAnyStatus,
          ),
          ...DecisionStatus.values.map(
            (status) => DropdownMenuEntry<DecisionStatus?>(
              value: status,
              label:
                  '${loc.attributeStatus}: '
                  '${getDecisionStatusUI(loc, status).label}',
            ),
          ),
        ]);

    return DefaultDropdownMenu<DecisionStatus?>(
      entries: menuEntries,
      initialSelection: initialStatus,
      onSelected: valueChanged,
    );
  }
}
