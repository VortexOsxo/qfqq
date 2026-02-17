import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/utils/validation.dart';
import 'package:qfqq/generated/l10n.dart';

class MeetingViewControl extends ConsumerWidget {
  final MeetingAgenda meeting;
  const MeetingViewControl({super.key, required this.meeting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<TextButton> buttons = [];

    switch (meeting.status) {
      case MeetingAgendaStatus.draft:
        buttons = draftButtons(context, ref);
      case MeetingAgendaStatus.planned:
        buttons = plannedButtons(context, ref);
      case MeetingAgendaStatus.ongoing:
        buttons = ongoingButtons(context, ref);
      case MeetingAgendaStatus.completed:
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: buttons,
    );
  }

  List<TextButton> draftButtons(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);

    final errors = validateMeetingAgenda(
      meeting,
      wantedStatus: MeetingAgendaStatus.planned,
    );

    final meetingsService = ref.read(meetingAgendaServiceProvider);

    return [
      TextButton(
        onPressed: () => context.go('/agenda', extra: meeting),
        child: Text(loc.commonModify),
      ),
      TextButton(
        onPressed:
            errors.hasAny()
                ? null
                : () => meetingsService.updateMeetingAgendaStatus(
                  meeting.id,
                  MeetingAgendaStatus.planned,
                ),
        child: Text(loc.meetingViewControlPlan),
      ),
    ];
  }

  List<TextButton> plannedButtons(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);

    final meetingsService = ref.read(meetingAgendaServiceProvider);

    return [
      TextButton(
        child: Text(loc.commonModify),
        onPressed: () => context.go('/agenda', extra: meeting),
      ),
      TextButton(
        child: Text(loc.commonStart),
        onPressed:
            () => meetingsService.updateMeetingAgendaStatus(
              meeting.id,
              MeetingAgendaStatus.ongoing,
            ),
      ),
    ];
  }

    List<TextButton> ongoingButtons(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);

    final meetingsService = ref.read(meetingAgendaServiceProvider);

    return [
      TextButton(
        child: Text(loc.meetingViewControlTerminate),
        onPressed:
            () => meetingsService.updateMeetingAgendaStatus(
              meeting.id,
              MeetingAgendaStatus.completed,
            ),
      ),
    ];
  }
}
