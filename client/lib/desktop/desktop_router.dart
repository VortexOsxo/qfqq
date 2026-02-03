import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/pages/agenda_modification_page.dart';
import 'package:qfqq/common/pages/agenda_view_page.dart';
import 'package:qfqq/common/pages/decisions_list_page.dart';
import 'package:qfqq/common/pages/home_page.dart';
import 'package:qfqq/common/pages/login_page.dart';
import 'package:qfqq/common/pages/meeting_in_progress_page.dart';
import 'package:qfqq/common/pages/project_modification_page.dart';
import 'package:qfqq/common/pages/project_page.dart';
import 'package:qfqq/common/pages/project_view_page.dart';
import 'package:qfqq/common/pages/signup_page.dart';
import 'package:qfqq/common/pages/agenda_list_page.dart';

final GoRouter desktopRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/agenda',
      builder: (context, state) {
        final agenda = state.extra as MeetingAgenda?;
        return AgendaModificationPage(agendaToModify: agenda);
      },
    ),
    GoRoute(
      path: '/agendas',
      builder: (context, state) => const AgendasListPage(),
    ),
    GoRoute(
      path: '/agendas/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AgendaViewPage(agendaId: id);
      },
    ),
    GoRoute(
      path: '/decisions',
      builder: (context, state) => const DecisionsListPage(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
    GoRoute(
      path: '/projects',
      builder: (context, state) => const ProjectPage(),
    ),
    GoRoute(
      path: '/project/creation',

      builder: (context, state) {
        final project = state.extra as Project?;
        return ProjectModificationPage(projectToModify: project);
      },
    ),
    GoRoute(
      path: '/project/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProjectViewPage(projectId: id);
      },
    ),
    GoRoute(
      path: '/meeting-in-progress/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return MeetingInProgressPage(id: id);
      },
    ),
  ],
);
