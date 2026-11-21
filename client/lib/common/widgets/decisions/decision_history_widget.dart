import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/models/decision_event.dart';
import 'package:qfqq/common/providers/decision_events_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/common/utils/get_status_ui.dart';
import 'package:qfqq/common/widgets/status_chip.dart';
import 'package:qfqq/generated/l10n.dart';

class DecisionHistoryWidget extends ConsumerWidget {
  final int decisionId;

  const DecisionHistoryWidget({super.key, required this.decisionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);
    final events = ref.watch(decisionEventsProvider(decisionId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.decisionHistoryTitle,
          style: contentSectionTitleTextStyle(Theme.of(context)),
        ),
        const SizedBox(height: 8),
        events.when(
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => const SizedBox.shrink(),
          data: (events) {
            if (events.isEmpty) return Text(loc.decisionHistoryEmpty);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < events.length; index++)
                  _DecisionHistoryEntry(
                    event: events[index],
                    isFirst: index == 0,
                    isLast: index == events.length - 1,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _DecisionHistoryEntry extends ConsumerWidget {
  final DecisionEvent event;
  final bool isFirst;
  final bool isLast;

  const _DecisionHistoryEntry({
    required this.event,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);
    final user = ref.watch(userByIdProvider(event.userId));
    final userName = user?.displayName ?? loc.decisionHistoryUser(event.userId);
    final statusValue = event.data?['decisionStatus'];
    final status =
        statusValue is String
            ? DecisionStatus.values.asNameMap()[statusValue]
            : null;
    final description = switch (event.type) {
      DecisionEventType.decisionCreated => loc.decisionHistoryCreated,
      DecisionEventType.statusUpdated =>
        status == null && statusValue is String
            ? loc.decisionHistoryStatusValue(statusValue)
            : loc.decisionHistoryStatusUpdated,
    };

    final color = Theme.of(context).primaryColor;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 10,
            child: Column(
              children: [
                SizedBox(
                  height: 5,
                  child: isFirst ? null : Container(width: 2, color: color),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child:
                      isLast
                          ? const SizedBox.shrink()
                          : Container(width: 2, color: color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatDate(context, event.date.toLocal())} \u2022 $userName',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (event.type == DecisionEventType.statusUpdated &&
                      status != null) ...[
                    const SizedBox(height: 8),
                    StatusChip(statusUIData: getDecisionStatusUI(loc, status)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
