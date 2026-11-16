import 'package:flutter/material.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/common/utils/platform.dart';
import 'package:qfqq/common/view_models/decision_view_page_view_model.dart';
import 'package:qfqq/common/widgets/details_attribute_widget.dart';
import 'package:qfqq/common/widgets/details_list_widget.dart';
import 'package:qfqq/common/widgets/navigation/navigation_text_button.dart';
import 'package:qfqq/generated/l10n.dart';

class DecisionDescriptionWidget extends StatelessWidget {
  final DecisionViewPageViewModelState vm;

  const DecisionDescriptionWidget({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final decision = vm.decision!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DetailsAttributeWidget(
          label: loc.attributeDate,
          value: formatDateDay(context, decision.initialDate),
        ),
        DetailsAttributeWidget(
          label: loc.decisionListDueDate,
          value: formatDateDayIfPresent(context, decision.dueDate),
        ),
        DetailsAttributeWidget(
          label: loc.decisionListResponsible,
          value:
              vm.responsibleName.isNotEmpty
                  ? vm.responsibleName
                  : loc.decisionListNoResponsibleSet,
        ),
        DetailsListWidget(
          label: loc.attributeAssitants,
          emptyLabel: loc.attributeNoAssistants,
          values: vm.assistantNames,
        ),
        const SizedBox(height: 4),
        if (vm.hasProject) ...[
          Text(
            loc.decisionViewPageProject,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          if (isDesktop) const SizedBox(height: 4),
          NavigationTextButton(
            title: loc.decisionViewPageGoToProject,
            navigate: vm.goToProject,
          ),
          if (isDesktop) const SizedBox(height: 8),
        ],
        if (vm.hasMeeting) ...[
          Text(
            loc.decisionViewPageMeeting,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          if (isDesktop) const SizedBox(height: 4),
          NavigationTextButton(
            title: loc.decisionViewPageGoToAgenda,
            navigate: vm.goToMeeting,
          ),
          if (isDesktop) const SizedBox(height: 8),
        ],
      ],
    );
  }
}
