import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/errors/meeting_agenda_errors.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/utils/validation.dart';
import 'package:qfqq/common/widgets/pdf_viewer_widget.dart';
import 'package:qfqq/generated/l10n.dart';

class MeetingViewContent extends ConsumerWidget {
  final MeetingAgenda meeting;
  const MeetingViewContent({super.key, required this.meeting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (meeting.status == MeetingAgendaStatus.draft) {
      return _draftContent(context, ref);
    } else if (meeting.status == MeetingAgendaStatus.planned) {
      return SizedBox();
    } else if (meeting.status == MeetingAgendaStatus.completed) {
      return _completedContent(context);
    }
    return SizedBox.shrink();
  }

  Widget _draftContent(BuildContext context, WidgetRef ref) {
    MeetingAgendaErrors errors = validateMeetingAgenda(
      meeting,
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
                  meeting.id,
                  MeetingAgendaStatus.planned,
                ),
            child: Text(loc.meetingViewContentMarkAsPlan),
          ),
        ],
      );
    }
  }

  Widget _completedContent(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);

    // TODO: Fix url
    final pdfUrl =
        'http://localhost:5000/meeting-agendas/${meeting.id}/reports?lang=${locale.languageCode}';

    return PdfViewerWidget(pdfUrl: pdfUrl);
  }
}
