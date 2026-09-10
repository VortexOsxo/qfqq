import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/models/errors/decision_errors.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/models/permissions.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/providers/decisions_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/utils/is_id_valid.dart';
import 'package:qfqq/common/utils/platform.dart';
import 'package:qfqq/common/utils/validation.dart';
import 'package:qfqq/common/widgets/permission_required.dart';
import 'package:qfqq/common/widgets/reusables/default_text_field.dart';
import 'package:qfqq/common/widgets/reusables/selection_text_fields/user_text_field.dart';
import 'package:qfqq/common/widgets/reusables/selection_text_fields/users_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

String _formatDate(DateTime date) => date.toIso8601String().split('T').first;

class MeetingViewContentOngoing extends StatelessWidget {
  final MeetingAgenda meeting;

  const MeetingViewContentOngoing({super.key, required this.meeting});

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).dividerColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(color: dividerColor, thickness: 1),
        PermissionRequired(
          neededPermissions: Permissions(contribute: true),
          child: _ComposeBar(meeting: meeting),
        ),
        Divider(color: dividerColor, thickness: 1),
        Expanded(child: _DecisionsFeed(meetingId: meeting.id)),
      ],
    );
  }
}

class _DecisionsFeed extends ConsumerWidget {
  final int meetingId;

  const _DecisionsFeed({required this.meetingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decisions = ref.watch(decisionsProvider).where((d) => d.meetingId == meetingId).toList();

    if (decisions.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      reverse: true,
      itemCount: decisions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final decision = decisions[index];
        final responsible = decision.responsibleId != null
            ? ref.watch(userByIdProvider(decision.responsibleId!))
            : null;

        return _DecisionCard(decision: decision, responsible: responsible);
      },
    );
  }
}

class _DecisionCard extends StatelessWidget {
  final Decision decision;
  final User? responsible;

  const _DecisionCard({required this.decision, this.responsible});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: theme.primaryColor, width: 3),
        ),
        color: theme.cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      padding: const EdgeInsets.all(10),

      // TODO: Decide if I should show the participants here
      child: Row(
        children: [
          Text(
            decision.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Icon(Icons.person_outline, size: 14, color: theme.hintColor),
          const SizedBox(width: 3),
          Text(
              responsible!.displayName,
              overflow: TextOverflow.ellipsis,
            ),
          
          const SizedBox(width: 8),
          Icon(Icons.calendar_today_outlined, size: 13, color: theme.hintColor),
          const SizedBox(width: 3),
          Text(_formatDate(decision.dueDate!)),
        ],
      ),
    );
  }
}

class _ComposeBar extends ConsumerStatefulWidget {
  final MeetingAgenda meeting;

  const _ComposeBar({required this.meeting});

  @override
  ConsumerState<_ComposeBar> createState() => _ComposeBarState();
}

class _ComposeBarState extends ConsumerState<_ComposeBar> {
  late Decision decision;
  int _resetCounter = 0;
  DecisionErrors errors = DecisionErrors();
  bool isSending = false;

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

  Future<void> _onSubmit() async {
    final decisionsService = ref.read(decisionsServiceProvider);

    final decisionsError = validateDecision(decision);
    if (decisionsError.hasAny()) {
      setState(() => errors = decisionsError);
      return;
    }

    setState(() => isSending = true);
    final serverErrors = await decisionsService.createDecision(decision);
    if (!mounted) return;
    setState(() => isSending = false);

    if (serverErrors.hasAny()) {
      setState(() => errors = serverErrors);
      return;
    }

    setState(() {
      _resetCounter++;
      _initDecision();
      errors = DecisionErrors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final theme = Theme.of(context);

    final isMobile = platformType == PlatformType.mobile;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DefaultTextField(
                key: ValueKey('desc_$_resetCounter'),
                onChanged: (desc) => decision.description = desc,
                hintText: loc.meetingInProgressDecision,
                error: errors.descriptionError,
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              height: 48,
              child: Center(
                child: IconButton(
                  onPressed: isSending ? null : _onSubmit,
                  icon:
                      isSending
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Icon(Icons.send, color: theme.primaryColor),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isMobile) ...[
          UserTextField(
            key: ValueKey('resp_$_resetCounter'),
            label: loc.meetingInProgressResponsible,
            onSelected: (User u) => decision.responsibleId = u.id,
            error: errors.responsibleError,
          ),
          SizedBox(height: 10),
          _dueDateField(loc),
        ] else
          Row(
            children: [
              Expanded(
                flex: 3,
                child: UserTextField(
                  key: ValueKey('resp_$_resetCounter'),
                  label: loc.meetingInProgressResponsible,
                  onSelected: (User u) => decision.responsibleId = u.id,
                  error: errors.responsibleError,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(flex: 1, child: _dueDateField(loc)),
            ],
          ),
        const SizedBox(height: 12),
        UsersTextField(
          key: ValueKey('assis_$_resetCounter'),
          onChanged:
              (List<User> u) =>
                  decision.assistantsIds = u.map((u) => u.id).toList(),
          label: loc.meetingInProgressParticipants,
        ),
      ],
    );
  }

  Widget _dueDateField(S loc) {
    final hasDate = decision.dueDate != null;
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: decision.dueDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() => decision.dueDate = picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: loc.meetingInProgressDueDate,
          errorText: errors.dueDateError,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(
          hasDate ? _formatDate(decision.dueDate!) : '',
          style: TextStyle(
            color: hasDate
                ? theme.textTheme.bodyLarge?.color
                : theme.hintColor,
          ),
        ),
      ),
    );
  }
}
