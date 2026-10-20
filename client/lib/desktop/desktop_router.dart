import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/pages/organizations/organization_invite_page.dart';
import 'package:qfqq/common/pages/organizations/organization_page.dart';
import 'package:qfqq/common/router.dart';
import 'package:qfqq/common/templates/navigation_guard.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/models/project.dart';
import 'package:qfqq/common/pages/agenda_modification_page.dart';
import 'package:qfqq/desktop/pages/agendas/agenda_view_page.dart';
import 'package:qfqq/common/pages/decisions_list_page.dart';
import 'package:qfqq/desktop/pages/decisions/decision_view_page.dart';
import 'package:qfqq/desktop/pages/home_page.dart';
import 'package:qfqq/common/pages/user_pages/forgotten_password_page.dart';
import 'package:qfqq/common/pages/project_modification_page.dart';
import 'package:qfqq/desktop/pages/projects/project_page.dart';
import 'package:qfqq/desktop/pages/projects/project_view_page.dart';
import 'package:qfqq/common/pages/user_pages/profile_page.dart';
import 'package:qfqq/desktop/pages/user_pages/signup_page.dart';
import 'package:qfqq/desktop/pages/agendas/agenda_list_page.dart';
import 'package:qfqq/common/pages/help_page.dart';
import 'package:qfqq/common/widgets/help/help_info.dart';
import 'package:qfqq/common/widgets/scaffolds/default_page_scaffold.dart';
import 'package:qfqq/common/utils/route_titles.dart';
import 'package:qfqq/desktop/pages/user_pages/login_page.dart';

NoTransitionPage _noTransition(Widget child) => NoTransitionPage(child: child);

class DesktopRouterBuilder extends RouterBuilder {
  @override
  Widget mainShellBuilder(BuildContext context, GoRouterState state, Widget child) {
    final title = getTitleForRoute(context, state);
    return defaultPageScaffold(context, child, title: title);
  }

  @override
  GoRoute routeBuilder(String path, BuilderType builder, [OnExitType? onExit]) {
    return GoRoute(
      path: path,
      onExit: onExit,
      pageBuilder: (c, s) => _noTransition(builder(c, s)),
    );
  }

  @override
  List<RoutePlan> mainShellRoutes() {
    return [
      RoutePlan('/', (c, s) => const HomePage()),
      RoutePlan(
        '/agendas/creation',
        (c, s) {
          final agenda = s.extra as MeetingAgenda?;
          return AgendaModificationPage(agendaToModify: agenda);
        },
        (c, s) => activeNavigationGuard?.call(c) ?? Future.value(true),
      ),
      RoutePlan('/agendas', (c, s) => const AgendasListPage()),
      RoutePlan('/agendas/:id', (c, s) {
        final id = s.pathParameters['id']!;
        return AgendaViewPage(agendaId: int.tryParse(id) ?? 0);
      }),
      RoutePlan('/decisions', (c, s) => const DecisionsListPage()),
      RoutePlan('/decisions/:id', (c, s) {
        final id = s.pathParameters['id']!;
        return DecisionViewPage(decisionId: int.tryParse(id) ?? 0);
      }),
      RoutePlan('/projects', (c, s) => const ProjectPage()),
      RoutePlan(
        '/projects/creation',
        (c, s) {
          final project = s.extra as Project?;
          return ProjectModificationPage(projectToModify: project);
        },
        (c, s) => activeNavigationGuard?.call(c) ?? Future.value(true),
      ),
      RoutePlan('/projects/:id', (c, s) {
        final id = s.pathParameters['id']!;
        return ProjectViewPage(projectId: int.tryParse(id) ?? 0);
      }),
      RoutePlan('/organization', (c, s) => const OrganizationPage()),
      RoutePlan('/organization/invite', (c, s) => const OrganizationInvitePage()),
      RoutePlan('/profile', (c, s) => const ProfilePage()),
      RoutePlan('/help', (c, s) => HelpPage(content: s.extra as HelpContent)),
    ];
  }

  
  @override
  List<RoutePlan> authShellRoutes() {
    return [
      RoutePlan('/login', (c, s) => const LoginPage()),
      RoutePlan('/signup', (c, s) => const SignupPage()),
      RoutePlan('/forgotten-password', (c, s) => const ForgottenPasswordPage()),
      
    ];
  }
}
