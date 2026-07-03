import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/models/permissions.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/common/utils/get_status_ui.dart';
import 'package:qfqq/common/view_models/decision_view_page_view_model.dart';
import 'package:qfqq/common/widgets/permission_required.dart';
import 'package:qfqq/common/widgets/reusables/form_filled_button.dart';
import 'package:qfqq/common/widgets/reusables/form_outlined_button.dart';
import 'package:qfqq/common/widgets/details_attribute_widget.dart';
import 'package:qfqq/common/widgets/details_list_widget.dart';
import 'package:qfqq/common/widgets/projects/project_title_link_widget.dart';
import 'package:qfqq/generated/l10n.dart';
import 'package:qfqq/mobile/widgets/title_with_status.dart';

class DecisionViewPage extends ConsumerWidget {
  final int decisionId;

  const DecisionViewPage({super.key, required this.decisionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DecisionViewPageViewModel(
      decisionId: decisionId,
      builder: (vm) => _DecisionViewPageContent(vm: vm),
    );
  }
}

class _DecisionViewPageContent extends StatelessWidget {
  final DecisionViewPageViewModelState vm;

  const _DecisionViewPageContent({required this.vm});

  @override
  Widget build(BuildContext context) {
    final decision = vm.decision;
    final loc = S.of(context);

    if (decision == null) {
      return Center(child: Text(loc.decisionNotFound));
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopCard(context, decision),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDecisionInfo(context, decision),
                
                Spacer(),

                if (vm.isInProgress) ...[
                  const SizedBox(height: 8),
                  IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FormFilledButton(
                          onPressed: vm.markAsCompleted,
                          text: loc.decisionViewPageMarkAsCompleted,
                        ),
                        const SizedBox(height: 8),
                        FormOutlinedButton(
                          onPressed: vm.markAsCancelled,
                          text: loc.decisionViewPageMarkAsCancelled,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCard(BuildContext context, Decision decision) {
    final loc = S.of(context);

    final uiData = getDecisionStatusUI(loc, decision.status);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TitleWithStatus(
            title: '${loc.attributeNumber}: ${decision.number}',
            uiData: uiData,
          ),
        ),

        Column(
          children: [
            if (vm.hasProject)
              ProjectTitleLinkWidget(
                projectId: decision.projectId!,
                minimized: true,
              ),
            if (vm.hasMeeting)
              TextButton(
                onPressed: vm.goToMeeting,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  minimumSize: Size(0, 30),
                ),
                child: Row(
                  children: [
                    Text(loc.decisionViewPageGoToAgenda),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDecisionInfo(BuildContext context, Decision decision) {
    final loc = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).decisionListDescription,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          decision.description,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        DetailsAttributeWidget(
          label: loc.attributeDate,
          value: formatDateDay(context, decision.initialDate),
        ),
        DetailsAttributeWidget(
          label: loc.decisionListDueDate,
          value:
              decision.dueDate != null
                  ? formatDateDay(context, decision.dueDate)
                  : loc.commonNoDateSet,
        ),
        if (decision.completedDate != null) ...[
          DetailsAttributeWidget(
            label: loc.decisionViewPageCompletedDate,
            value: formatDateDay(context, decision.completedDate),
          ),
        ],
        DetailsAttributeWidget(
          label: loc.decisionListResponsible,
          value:
              vm.responsibleName.isNotEmpty
                  ? vm.responsibleName
                  : loc.decisionListNoResponsibleSet,
        ),
        DetailsListWidget(
          label: loc.attributeAssitants,
          emptyLabel: loc.attributeNoAssitants,
          values: vm.assistantNames,
        ),

        Spacer(),
        PermissionRequired(
          neededPermissions: Permissions(deleteContent: true),
          child: TextButton(
            onPressed: vm.deleteDecision,
            child: Text(loc.commonDelete),
          ),
        ),
      ],
    );
  }
}
