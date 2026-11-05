import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/widgets/agenda_view_page/meeting_view_content_completed.dart';
import 'package:qfqq/common/widgets/agenda_view_page/meeting_view_content_draft.dart';
import 'package:qfqq/common/widgets/agenda_view_page/meeting_view_content_ongoing.dart';
import 'package:qfqq/common/widgets/agenda_view_page/meeting_view_content_planned.dart';

class MeetingViewContent extends ConsumerWidget {
  final MeetingAgenda meeting;
  const MeetingViewContent({super.key, required this.meeting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (meeting.status) {
      case MeetingAgendaStatus.draft:
        return MeetingViewContentDraft(meeting: meeting);
      case MeetingAgendaStatus.planned:
        return MeetingViewContentPlanned(meeting: meeting);
      case MeetingAgendaStatus.canceled:
        return const SizedBox();
      case MeetingAgendaStatus.ongoing:
        return MeetingViewContentOngoing(meeting: meeting);
      case MeetingAgendaStatus.completed:
        return MeetingViewContentCompleted(meeting);
    }
  }
}
