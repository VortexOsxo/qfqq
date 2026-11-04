import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/models/project.dart';

class ReportConfig {
  final String pdfUrl;
  final String pdfName;
  final bool hasProjectFilter;
  final bool hasResponsibleFilter;
  final bool hasStatusFilter;

  const ReportConfig({
    required this.pdfUrl,
    required this.pdfName,
    this.hasProjectFilter = true,
    this.hasResponsibleFilter = true,
    this.hasStatusFilter = true,
  });

  bool get hasFilter => hasProjectFilter || hasResponsibleFilter || hasStatusFilter;

  factory ReportConfig.forMeeting(MeetingAgenda meeting) => ReportConfig(
    pdfUrl: 'reports/meeting-agendas/${meeting.id}',
    pdfName: meeting.title,
    hasProjectFilter: false,
  );

  factory ReportConfig.forProject(Project project) => ReportConfig(
    pdfUrl: 'reports/projects/${project.id}',
    pdfName: project.title,
    hasProjectFilter: false,
  );

  factory ReportConfig.forParticipants() => ReportConfig(
    pdfUrl: 'reports/participants',
    pdfName: 'participants-report',
  );
}
