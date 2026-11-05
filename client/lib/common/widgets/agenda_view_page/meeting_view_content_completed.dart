import 'package:flutter/material.dart';
import 'package:qfqq/common/models/configs/report_config.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/widgets/meeting_review_list.dart';
import 'package:qfqq/common/widgets/report_pdf_viewer.dart';
import 'package:qfqq/generated/l10n.dart';

class MeetingViewContentCompleted extends StatelessWidget {
  final MeetingAgenda meeting;

  const MeetingViewContentCompleted(this.meeting, {super.key});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: loc.commonObjectReports),
              Tab(text: loc.commonObjectReviews),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                ReportPdfViewer(config: ReportConfig.forMeeting(meeting)),
                MeetingReviewList(meetingId: meeting.id),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
