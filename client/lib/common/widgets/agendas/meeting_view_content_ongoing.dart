import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/providers/decisions_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/utils/is_id_valid.dart';
import 'package:qfqq/common/widgets/reusables/default_text_field.dart';
import 'package:qfqq/common/widgets/reusables/selection_text_fields/user_text_field.dart';
import 'package:qfqq/common/widgets/reusables/selection_text_fields/users_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

class MeetingViewContentOngoing extends ConsumerWidget {
  final MeetingAgenda meeting;

  const MeetingViewContentOngoing({super.key, required this.meeting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);
    final decisions = ref.watch(decisionsProvider);

    final meetingDecisions =
        decisions.where((d) => d.meetingId == meeting.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CreateDecisionForm(meeting: meeting),
        _takenDecisions(loc, meetingDecisions, ref),
      ],
    );
  }

  Widget _takenDecisions(
    S loc,
    List<Decision> meetingDecisions,
    WidgetRef ref,
  ) {
    if (meetingDecisions.isEmpty) return const SizedBox.shrink();

    return Expanded(
      child: ListView.builder(
        itemCount: meetingDecisions.length,
        itemBuilder: (context, index) {
          final revIndex = meetingDecisions.length - 1 - index;
          final decision = meetingDecisions[revIndex];
          final responsible =
              decision.responsibleId != null
                  ? ref.watch(userByIdProvider(decision.responsibleId!))
                  : null;
          return ListTile(
            title: Text(decision.description),
            subtitle: Row(
              children: [
                if (responsible != null)
                  Expanded(
                    child: Text(
                      '${loc.decisionListResponsible}: ${responsible.displayName}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (decision.dueDate != null)
                  Expanded(
                    child: Text(
                      '${loc.decisionListDueDate}: ${decision.dueDate!.toIso8601String().split('T').first}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CreateDecisionForm extends ConsumerStatefulWidget {
  final MeetingAgenda meeting;

  const _CreateDecisionForm({required this.meeting});

  @override
  ConsumerState<_CreateDecisionForm> createState() =>
      _CreateDecisionFormState();
}

class _CreateDecisionFormState extends ConsumerState<_CreateDecisionForm> {
  late Decision decision;
  int _resetCounter = 0;

  @override
  void initState() {
    super.initState();
    _initDecision();
  }

  void _initDecision() {
    decision = Decision.empty()..projectId = widget.meeting.projectId;
    if (isIdValid(widget.meeting.id)) {
      decision.meetingId = widget.meeting.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final decisionsService = ref.read(decisionsServiceProvider);

    void onSubmit() async {
      await decisionsService.createDecision(decision);
      if (!mounted) return;

      setState(() {
        _resetCounter++;
        _initDecision();
      });
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  loc.meetingInProgressTakeDecision,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: decision.dueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );

                    if (picked != null) {
                      setState(() {
                        decision.dueDate = picked;
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: Text(
                    decision.dueDate == null
                        ? loc.meetingInProgressDueDate
                        : loc.meetingInProgressDueDateSelected(
                          decision.dueDate!.toIso8601String().split('T').first,
                        ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onSubmit,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(loc.meetingInProgressCreateButton),
                  style: squareButtonStyleSmall(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DefaultTextField(
              key: ValueKey('desc_$_resetCounter'),
              onChanged: (String desc) => decision.description = desc,
              hintText: loc.meetingInProgressDecision,
            ),
            const SizedBox(height: 12),
            UserTextField(
              key: ValueKey('resp_$_resetCounter'),
              label: loc.meetingInProgressResponsible,
              onSelected: (User u) => decision.responsibleId = u.id,
            ),
            const SizedBox(height: 12),
            UsersTextField(
              key: ValueKey('assis_$_resetCounter'),
              onChanged:
                  (List<User> u) =>
                      decision.assistantsIds = u.map((u) => u.id).toList(),
              label: loc.meetingInProgressParticipants,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
