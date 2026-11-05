import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/errors/meeting_agenda_errors.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/utils/help_util.dart';
import 'package:qfqq/common/utils/validation.dart';
import 'package:qfqq/common/widgets/help/help_button.dart';
import 'package:qfqq/generated/l10n.dart';

class MeetingViewContentDraft extends ConsumerWidget {
  final MeetingAgenda meeting;

  const MeetingViewContentDraft({super.key, required this.meeting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    MeetingAgendaErrors errors = validateMeetingAgenda(
      meeting,
      wantedStatus: MeetingAgendaStatus.planned,
    );

    final loc = S.of(context);
    final currentUser = ref.watch(authStateProvider).user;
    final isAnimator = currentUser != null && meeting.animatorId == currentUser.id;
    final helpLink = isAnimator
            ? MeetingAnimationHelpLink(loc: loc)
            : MeetingParticipationHelpLink(loc: loc);
    final meetingsService = ref.read(meetingAgendaServiceProvider);

    final titleRow = Row(
      children: [
        Expanded(
          child: Text(
            errors.hasAny()
                ? loc.meetingViewContentDraftCorrectErrors
                : loc.meetingViewContentDraftMarkPlanned,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        HelpButton(helpLink: helpLink),
      ],
    );

    if (errors.hasAny()) {
      List<String> errorsMessages = errors.getErrorsMessages();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleRow,
          ...errorsMessages.map((message) => Text('    $message')),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleRow,
          TextButton(
            onPressed:
                () => meetingsService.updateMeetingAgendaStatus(
                  meeting.id,
                  MeetingAgendaStatus.planned,
                ),
            child: Text(loc.meetingViewContentMarkAsPlan),
          ),
        ],
      );
    }
  }
}
