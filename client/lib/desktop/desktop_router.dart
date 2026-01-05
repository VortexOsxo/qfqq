import 'package:go_router/go_router.dart';
import 'package:qfqq/common/pages/agenda_modification__page.dart';
import 'package:qfqq/common/pages/home_page.dart';
import 'package:qfqq/common/pages/login_page.dart';
import 'package:qfqq/common/pages/meeting_in_progress_page.dart';
import 'package:qfqq/common/pages/meeting_page.dart';
import 'package:qfqq/common/pages/meeting_selection_page.dart';
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
      builder: (context, state) => AgendaModificationPage(),
    ),
    GoRoute(
      path: '/agendas',
      builder: (context, state) => const AgendasListPage(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
    GoRoute(
      path: '/projects',
      builder: (context, state) => const ProjectPage(),
    ),
    GoRoute(
      path: '/project/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProjectViewPage(projectId: id);
      },
    ),
    GoRoute(
      path: '/meeting-selection',
      builder: (context, state) => const MeetingSelectionPage(),
    ),
    GoRoute(
      path: '/meeting-in-progress/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return MeetingInProgressPage(id: id);
      },
    ),
    GoRoute(path: '/meeting', builder: (context, state) => const MeetingPage()),
  ],
);
