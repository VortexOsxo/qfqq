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
import 'package:qfqq/common/widgets/status_chip.dart';
import 'package:qfqq/common/widgets/details_attribute_widget.dart';
import 'package:qfqq/common/widgets/details_list_widget.dart';
import 'package:qfqq/common/widgets/projects/project_title_link_widget.dart';
import 'package:qfqq/generated/l10n.dart';

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
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          _buildTopCard(context, decision),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 300,
                  child: _buildDecisionInfo(context, decision),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).decisionListDescription,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        decision.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildTopCard(BuildContext context, Decision decision) {
    final theme = Theme.of(context);
    final loc = S.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${loc.attributeNumber}: ${decision.number}',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          ProjectTitleLinkWidget(projectId: decision.projectId ?? 0),
        ],
      ),
    );
  }

  Widget _buildDecisionInfo(BuildContext context, Decision decision) {
    final loc = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatusChip(
          statusUIData: getDecisionStatusUI(S.of(context), decision.status),
        ),
        const SizedBox(height: 12),
        DetailsAttributeWidget(
          label: loc.attributeDate,
          value: formatDate(context, decision.initialDate),
        ),
        DetailsAttributeWidget(
          label: loc.decisionListDueDate,
          value:
              decision.dueDate != null
                  ? formatDate(context, decision.dueDate)
                  : loc.commonNoDateSet,
        ),
        if (decision.completedDate != null) ...[
          DetailsAttributeWidget(
            label: loc.decisionViewPageCompletedDate,
            value: formatDate(context, decision.completedDate),
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
        if (vm.hasMeeting) ...[
          Text(
            loc.decisionViewPageMeeting,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
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
          const SizedBox(height: 16),
        ],
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
