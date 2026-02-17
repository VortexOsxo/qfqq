import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/providers/decisions_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/common/utils/is_id_valid.dart';
import 'package:qfqq/common/widgets/details_attribute_widget.dart';
import 'package:qfqq/common/widgets/projects/project_title_link_widget.dart';
import 'package:qfqq/generated/l10n.dart';

class DecisionViewPage extends ConsumerWidget {
  final int decisionId;

  const DecisionViewPage({super.key, required this.decisionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);
    final decision = ref.watch(decisionByIdProvider(decisionId));


    if (decision == null) {
      return Center(child: Text(loc.decisionNotFound));
    }

    return _buildContent(context, ref, decision);
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Decision decision) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          _buildTopCard(context, ref, decision),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 300,
                  child: _buildDecisionInfo(context, ref, decision),
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

  Widget _buildTopCard(BuildContext context, WidgetRef ref, Decision decision) {
    final loc = S.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${loc.decisionListNumber}: ${decision.number}',
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

  Widget _buildDecisionInfo(
    BuildContext context,
    WidgetRef ref,
    Decision decision,
  ) {
    final loc = S.of(context);

    final responsible =
        isIdValid(decision.responsibleId)
            ? ref.watch(userByIdProvider(decision.responsibleId!))
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DetailsAttributeWidget(
          label: loc.attributeStatus,
          value: getDecisionStatusName(decision.status),
        ),
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
          value: responsible?.username ?? loc.decisionListNoResponsibleSet,
        ),
        if (isIdValid(decision.meetingId)) ...[
          Text(
            loc.decisionViewPageMeeting,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed:
                () => context.go(
                  '/agendas/${decision.meetingId}',
                ), // Assuming this route exists based on AgendaViewPage usage
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
        if (decision.assistantsIds.isNotEmpty) ...[
          Text(
            loc.attributeParticipants, // TODO: use proper label
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          ...decision.assistantsIds.map((id) {
            final user = ref.watch(userByIdProvider(id));
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(user?.username ?? loc.commonUnknown),
            );
          }),
        ],
      ],
    );
  }
}
