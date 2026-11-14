import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/models/project.dart';

class ReportConfig {
  // Ids match the column definitions in the backend report columns.
  static const numberColumn = 1;
  static const meetingColumn = 2;
  static const descriptionColumn = 3;
  static const responsibleColumn = 4;
  static const dueDateColumn = 5;
  static const statusColumn = 6;
  static const completedDateColumn = 7;

  static const participantColumns = [
    numberColumn,
    descriptionColumn,
    dueDateColumn,
    statusColumn,
    completedDateColumn,
  ];
  static const meetingColumns = [
    numberColumn,
    descriptionColumn,
    responsibleColumn,
    dueDateColumn,
    statusColumn,
    completedDateColumn,
  ];
  static const projectColumns = [
    numberColumn,
    meetingColumn,
    descriptionColumn,
    responsibleColumn,
    dueDateColumn,
    statusColumn,
    completedDateColumn,
  ];

  final String pdfUrl;
  final String pdfName;
  final bool hasProjectFilter;
  final bool hasResponsibleFilter;
  final bool hasStatusFilter;
  final bool hasComments;
  final List<int> availableColumns;

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
