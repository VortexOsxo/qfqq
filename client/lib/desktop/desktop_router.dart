import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/pages/organizations/organization_invite_page.dart';
import 'package:qfqq/common/pages/organizations/organization_page.dart';
import 'package:qfqq/common/providers/navigator_key.dart';
import 'package:qfqq/common/templates/navigation_guard.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/pages/agenda_modification_page.dart';
import 'package:qfqq/common/pages/agenda_view_page.dart';
import 'package:qfqq/common/pages/decisions_list_page.dart';
import 'package:qfqq/common/pages/decision_view_page.dart';
import 'package:qfqq/desktop/pages/home_page.dart';
import 'package:qfqq/common/pages/user_pages/forgotten_password_page.dart';
import 'package:qfqq/common/pages/project_modification_page.dart';
import 'package:qfqq/desktop/pages/projects/project_page.dart';
import 'package:qfqq/desktop/pages/projects/project_view_page.dart';
import 'package:qfqq/common/pages/decisions_report_page.dart';
import 'package:qfqq/common/pages/user_pages/profile_page.dart';
import 'package:qfqq/desktop/pages/user_pages/signup_page.dart';
import 'package:qfqq/desktop/pages/agendas/agenda_list_page.dart';
import 'package:qfqq/common/pages/user_pages/organization_links_page.dart';
import 'package:qfqq/common/widgets/scaffolds/auth_page_scaffold.dart';

import 'package:qfqq/common/widgets/scaffolds/default_page_scaffold.dart';
import 'package:qfqq/common/utils/route_titles.dart';
import 'package:qfqq/desktop/pages/user_pages/login_page.dart';

NoTransitionPage _noTransition(Widget child) => NoTransitionPage(child: child);

final GoRouter desktopRouter = GoRouter(
  initialLocation: '/login',
  navigatorKey: navigatorKey,
  routes: [
    ShellRoute(
      builder:
          (context, state, child) => defaultPageScaffold(
            context,
            child,
            title: getTitleForRoute(context, state),
          ),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => _noTransition(const HomePage()),
        ),
        GoRoute(
          path: '/agendas/creation',
          onExit: (context, state) => activeNavigationGuard?.call(context) ?? Future.value(true),
          pageBuilder: (context, state) {
            final agenda = state.extra as MeetingAgenda?;
            return _noTransition(
              AgendaModificationPage(agendaToModify: agenda),
            );
          },
        ),
        GoRoute(
          path: '/agendas',
          pageBuilder:
              (context, state) => _noTransition(const AgendasListPage()),
        ),
        GoRoute(
          path: '/agendas/:id',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            return _noTransition(
              AgendaViewPage(agendaId: int.tryParse(id) ?? 0),
            );
          },
        ),
        GoRoute(
          path: '/decisions',
          pageBuilder:
              (context, state) => _noTransition(const DecisionsListPage()),
        ),
        GoRoute(
          path: '/decisions/report',
          pageBuilder: (context, state) => _noTransition(const DecisionsReportPage()),
        ),
        GoRoute(
          path: '/decisions/:id',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            return _noTransition(
              DecisionViewPage(decisionId: int.tryParse(id) ?? 0),
            );
          },
        ),
        GoRoute(
          path: '/projects',
          pageBuilder: (context, state) => _noTransition(const ProjectPage()),
        ),
        GoRoute(
          path: '/projects/creation',
          onExit: (context, state) => activeNavigationGuard?.call(context) ?? Future.value(true),
          pageBuilder: (context, state) {
            final project = state.extra as Project?;
            return _noTransition(
              ProjectModificationPage(projectToModify: project),
            );
          },
        ),
        GoRoute(
          path: '/projects/:id',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            return _noTransition(
              ProjectViewPage(projectId: int.tryParse(id) ?? 0),
            );
          },
        ),
        GoRoute(
          path: '/organization',
          pageBuilder: (context, state) => _noTransition(const OrganizationPage()),
        ),
        GoRoute(
          path: '/organization/invite',
          pageBuilder: (context, state) => _noTransition(const OrganizationInvitePage()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => _noTransition(const ProfilePage()),
        ),
      ],
    ),

    ShellRoute(
      builder:
          (context, state, child) => authPageScaffold(
            context,
            child,
            title: getTitleForRoute(context, state),
          ),
      routes: [
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => _noTransition(const LoginPage()),
        ),
        GoRoute(
          path: '/signup',
          pageBuilder: (context, state) => _noTransition(const SignupPage()),
        ),
        GoRoute(
          path: '/forgotten-password',
          pageBuilder: (context, state) => _noTransition(const ForgottenPasswordPage()),
        ),
      ],
    ),
    GoRoute(
      path: '/organizations/links',
      pageBuilder: (context, state) => _noTransition(const OrganizationLinksPage()),
    ),
  ],
);

