import 'package:go_router/go_router.dart';
import 'package:qfqq/common/templates/navigation_guard.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/pages/agenda_modification_page.dart';
import 'package:qfqq/common/pages/agenda_view_page.dart';
import 'package:qfqq/common/pages/decisions_list_page.dart';
import 'package:qfqq/common/pages/decision_view_page.dart';
import 'package:qfqq/common/pages/home_page.dart';
import 'package:qfqq/common/pages/user_pages/forgotten_password_page.dart';
import 'package:qfqq/common/pages/project_modification_page.dart';
import 'package:qfqq/common/pages/project_page.dart';
import 'package:qfqq/common/pages/project_view_page.dart';
import 'package:qfqq/common/pages/user_pages/profile_page.dart';
import 'package:qfqq/mobile/pages/user_pages/signup_page.dart';
import 'package:qfqq/common/pages/agenda_list_page.dart';
import 'package:qfqq/common/widgets/scaffolds/auth_page_scaffold.dart';
import 'package:qfqq/common/widgets/scaffolds/mobile_page_scaffold.dart';
import 'package:qfqq/common/utils/route_titles.dart';
import 'package:qfqq/mobile/pages/user_pages/login_page.dart';

final GoRouter mobileRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    ShellRoute(
      builder: (context, state, child) => mobilePageScaffold(
        context,
        child,
        title: getTitleForRoute(context, state),
      ),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/agenda',
          onExit: (context, state) => activeNavigationGuard?.call(context) ?? Future.value(true),
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
            return AgendaViewPage(agendaId: int.tryParse(id) ?? 0);
          },
        ),
        GoRoute(
          path: '/decisions',
          builder: (context, state) => const DecisionsListPage(),
        ),
        GoRoute(
          path: '/decisions/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return DecisionViewPage(decisionId: int.tryParse(id) ?? 0);
          },
        ),
        GoRoute(
          path: '/projects',
          builder: (context, state) => const ProjectPage(),
        ),
        GoRoute(
          path: '/project/creation',
          onExit: (context, state) => activeNavigationGuard?.call(context) ?? Future.value(true),
          builder: (context, state) {
            final project = state.extra as Project?;
            return ProjectModificationPage(projectToModify: project);
          },
        ),
        GoRoute(
          path: '/project/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ProjectViewPage(projectId: int.tryParse(id) ?? 0);
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),

    ShellRoute(
      builder: (context, state, child) => authPageScaffold(
        context,
        child,
        title: getTitleForRoute(context, state),
      ),
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupPage(),
        ),
        GoRoute(
          path: '/forgotten-password',
          builder: (context, state) => const ForgottenPasswordPage(),
        ),
      ],
    ),
  ],
);

