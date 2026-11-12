import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/models/project.dart';

class ReportConfig {
  static const participantColumns = [
    'number',
    'description',
    'dueDate',
    'status',
    'completedDate',
  ];
  static const meetingColumns = [
    'number',
    'description',
    'responsible',
    'dueDate',
    'status',
    'completedDate',
  ];
  static const projectColumns = [
    'number',
    'meetingId',
    'description',
    'responsible',
    'dueDate',
    'status',
    'completedDate',
  ];

  final String pdfUrl;
  final String pdfName;
  final bool hasProjectFilter;
  final bool hasResponsibleFilter;
  final bool hasStatusFilter;
  final bool hasComments;
  final List<String> availableColumns;

  const ReportConfig({
    required this.pdfUrl,
    required this.pdfName,
    this.hasProjectFilter = true,
    this.hasResponsibleFilter = true,
    this.hasStatusFilter = true,
    this.hasComments = false,
    this.availableColumns = participantColumns,
  });

  bool get hasFilter => hasProjectFilter || hasResponsibleFilter || hasStatusFilter;

  factory ReportConfig.forMeeting(MeetingAgenda meeting) => ReportConfig(
    pdfUrl: 'reports/meeting-agendas/${meeting.id}',
    pdfName: meeting.title,
    hasProjectFilter: false,
    hasComments: true,
    availableColumns: meetingColumns,
  );

  factory ReportConfig.forProject(Project project) => ReportConfig(
    pdfUrl: 'reports/projects/${project.id}',
    pdfName: project.title,
    hasProjectFilter: false,
    availableColumns: projectColumns,
  );

  factory ReportConfig.forParticipants() => ReportConfig(
    pdfUrl: 'reports/participants',
    pdfName: 'participants-report',
  );
}
