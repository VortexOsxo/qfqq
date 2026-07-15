import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/errors/meeting_agenda_errors.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/providers/decisions_provider.dart';
import 'package:qfqq/common/services/meeting_agenda_service.dart';
import 'package:qfqq/common/widgets/agendas/meeting_view_content_completed.dart';
import 'package:qfqq/common/widgets/agendas/meeting_view_content_ongoing.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/utils/validation.dart';
import 'package:qfqq/generated/l10n.dart';

class MeetingViewContent extends ConsumerStatefulWidget {
  final MeetingAgenda meeting;
  const MeetingViewContent({super.key, required this.meeting});

  @override
  ConsumerState<MeetingViewContent> createState() => _MeetingViewContentState();
}

class _MeetingViewContentState extends ConsumerState<MeetingViewContent> {
  MeetingAgendaService? service;

  void _onJoinMeeting() {
    service = ref.read(meetingAgendaServiceProvider);
    service?.joinMeeting(widget.meeting.id);

    ref.read(decisionsServiceProvider).reload(); // TODO: Optimize
  }

  void _onLeaveMeeting() {
    service?.leaveMeeting(widget.meeting.id);
    service = null;
  }

  @override
  void initState() {
    super.initState();
    _onJoinMeeting();
  }

  @override
  void dispose() {
    _onLeaveMeeting();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.meeting.status) {
      case MeetingAgendaStatus.draft:
        return _draftContent(context, ref);
      case MeetingAgendaStatus.planned:
      case MeetingAgendaStatus.canceled:
        return SizedBox();
      case MeetingAgendaStatus.ongoing:
        return MeetingViewContentOngoing(meeting: widget.meeting);
      case MeetingAgendaStatus.completed:
        return MeetingViewContentCompleted(widget.meeting);
    }
  }

  Widget _draftContent(BuildContext context, WidgetRef ref) {
    MeetingAgendaErrors errors = validateMeetingAgenda(
      widget.meeting,
      wantedStatus: MeetingAgendaStatus.planned,
    );

    final loc = S.of(context);

    final meetingsService = ref.read(meetingAgendaServiceProvider);

    if (errors.hasAny()) {
      List<String> errorsMessages = errors.getErrorsMessages();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.meetingViewContentDraftCorrectErrors,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...errorsMessages.map((message) => Text('    $message')),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.meetingViewContentDraftMarkPlanned,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed:
                () => meetingsService.updateMeetingAgendaStatus(
                  widget.meeting.id,
                  MeetingAgendaStatus.planned,
                ),
            child: Text(loc.meetingViewContentMarkAsPlan),
          ),
        ],
      );
    }
  }
}
