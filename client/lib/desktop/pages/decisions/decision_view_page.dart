import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/models/permissions.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/common/utils/get_status_ui.dart';
import 'package:qfqq/common/view_models/decision_view_page_view_model.dart';
import 'package:qfqq/common/widgets/decisions/decision_description_widget.dart';
import 'package:qfqq/common/widgets/decisions/decision_history_widget.dart';
import 'package:qfqq/common/widgets/decisions/decision_status_control_widget.dart';
import 'package:qfqq/common/widgets/navigation/navigation_text_button.dart';
import 'package:qfqq/common/widgets/permission_required.dart';
import 'package:qfqq/common/widgets/status_chip.dart';
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
    final theme = Theme.of(context);

    if (decision == null) {
      return Center(child: Text(loc.decisionNotFound));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProjectAndMeetingNavigationTextLink(projectId: vm.projectId, meetingId: vm.meetingId),
          SizedBox(height: 8),
          Text(
            '${loc.attributeNumber}: ${decision.number}',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 180,
                  child: _buildDecisionInfo(context, decision),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _internalContent(context, loc, theme, decision),
                      ),
                      const SizedBox(height: 8),
                      DecisionsStatusControlWidget(vm: vm),
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

  Widget _internalContent(BuildContext context, S loc, ThemeData theme, Decision decision) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.decisionListDescription,
            style: contentSectionTitleTextStyle(Theme.of(context)),
          ),
          const SizedBox(height: 16),
          Text(decision.description, style: theme.textTheme.bodyLarge),
          if (decision.completedDate != null ||
              decision.completedMessage?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 16),
            _buildCompletionDetails(context, loc, theme, decision),
          ],
          const SizedBox(height: 24),
          DecisionHistoryWidget(decisionId: decision.id),
        ],
      ),
    );
  }

  Widget _buildCompletionDetails(BuildContext context, S loc, ThemeData theme, Decision decision) {
    final hasMessage = decision.completedMessage?.trim().isNotEmpty == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasMessage) ...[
          Text(
            loc.decisionViewPageOutcome,
            style: contentSectionTitleTextStyle(theme),
          ),
          const SizedBox(height: 4),
          Text(
            decision.completedMessage!,
            style: theme.textTheme.bodyLarge,
          ),
        ],
        if (decision.completedDate != null) ...[
          if (hasMessage) const SizedBox(height: 8),
          Text(
            loc.decisionViewPageCompletedOn(
              formatDate(context, decision.completedDate),
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
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
        DecisionDescriptionWidget(vm: vm),
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
