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

    if (meeting.status == MeetingAgendaStatus.draft) {
      buttons = draftButtons(context, ref);
    } else if (meeting.status == MeetingAgendaStatus.planned) {
      buttons = plannedButtons(context);
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

  List<TextButton> plannedButtons(BuildContext context) {
    final loc = S.of(context);

    return [
      TextButton(
        child: Text(loc.commonModify),
        onPressed: () => context.go('/agenda', extra: meeting),
      ),
      TextButton(
        child: Text(loc.commonStart),
        onPressed: () => context.go('/meeting-in-progress/${meeting.id}'),
      ),
    ];
  }
}
