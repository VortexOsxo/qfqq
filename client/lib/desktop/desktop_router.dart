import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/pages/agenda_modification_page.dart';
import 'package:qfqq/common/pages/agenda_view_page.dart';
import 'package:qfqq/common/pages/decisions_list_page.dart';
import 'package:qfqq/common/pages/decision_view_page.dart';
import 'package:qfqq/common/pages/home_page.dart';
import 'package:qfqq/common/pages/login_page.dart';
import 'package:qfqq/common/pages/project_modification_page.dart';
import 'package:qfqq/common/pages/project_page.dart';
import 'package:qfqq/common/pages/project_view_page.dart';
import 'package:qfqq/common/pages/signup_page.dart';
import 'package:qfqq/common/pages/agenda_list_page.dart';

import 'package:qfqq/common/widgets/scaffolds/default_page_scaffold.dart';
import 'package:qfqq/generated/l10n.dart';

NoTransitionPage _noTransition(Widget child) => NoTransitionPage(child: child);

final GoRouter desktopRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    ShellRoute(
      builder: (context, state, child) => defaultPageScaffold(
        context,
        child,
        title: _getTitleForRoute(context, state),
      ),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => _noTransition(const HomePage()),
        ),
        GoRoute(
          path: '/agenda',
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
          path: '/project/creation',
          pageBuilder: (context, state) {
            final project = state.extra as Project?;
            return _noTransition(
              ProjectModificationPage(projectToModify: project),
            );
          },
        ),
        GoRoute(
          path: '/project/:id',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            return _noTransition(
              ProjectViewPage(projectId: int.tryParse(id) ?? 0),
            );
          },
        ),
      ],
    ),

    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
  ],
);

String? _getTitleForRoute(BuildContext context, GoRouterState state) {
  final loc = S.of(context);
  final fullPath = state.fullPath;
  
  if (fullPath == null) return null;

  switch (fullPath) {
    case '/':
      return loc.homePageTitle;
    case '/agenda':
      final agenda = state.extra as MeetingAgenda?;
      return agenda == null 
          ? '${loc.agendaPageTitleAppBar} - Create' 
          : '${loc.agendaPageTitleAppBar} - Update';
    case '/agendas':
      return loc.agendasListPageTitle;
    case '/agendas/:id':
      return loc.agendaPageTitleAppBar;
    case '/decisions':
      return loc.decisionsListPageTitle;
    case '/decisions/:id':
      return loc.decisionViewPageTitle;
    case '/projects':
      return loc.projectPageTitle;
    case '/project/creation':
      return loc.projectModificationPageTitle;
    case '/project/:id':
      return loc.projectViewPageTitle;
    default:
      return null;
  }
}
