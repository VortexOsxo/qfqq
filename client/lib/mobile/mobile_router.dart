import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/pages/help_page.dart';
import 'package:qfqq/common/router.dart';
import 'package:qfqq/common/widgets/help/help_info.dart';
import 'package:qfqq/mobile/pages/agendas/agenda_view_page.dart';
import 'package:qfqq/common/pages/decisions_list_page.dart';
import 'package:qfqq/mobile/pages/decisions/decision_view_page.dart';
import 'package:qfqq/mobile/pages/home_page.dart';
import 'package:qfqq/common/pages/user_pages/forgotten_password_page.dart';
import 'package:qfqq/mobile/pages/projects/project_page.dart';
import 'package:qfqq/mobile/pages/projects/project_view_page.dart';
import 'package:qfqq/common/pages/user_pages/profile_page.dart';
import 'package:qfqq/mobile/pages/user_pages/signup_page.dart';
import 'package:qfqq/mobile/pages/agendas/agenda_list_page.dart';
import 'package:qfqq/common/widgets/scaffolds/mobile_page_scaffold.dart';
import 'package:qfqq/common/utils/route_titles.dart';
import 'package:qfqq/mobile/pages/user_pages/login_page.dart';

class MobileRouterBuilder extends RouterBuilder {
  @override
  Widget mainShellBuilder(BuildContext context, GoRouterState state, Widget child) {
    final title = getTitleForRoute(context, state);
    return mobilePageScaffold(context, child, title: title);
  }

  @override
  GoRoute routeBuilder(String path, BuilderType builder, [OnExitType? onExit]) {
    return GoRoute(
      path: path,
      onExit: onExit,
      pageBuilder: (c, s) => MaterialPage(key: s.pageKey, child: builder(c, s)),
    );
  }

  @override
  List<RoutePlan> mainShellRoutes() {
    return [
      RoutePlan('/', (c, s) => const HomePage()),
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
      RoutePlan('/projects/:id', (c, s) {
        final id = s.pathParameters['id']!;
        return ProjectViewPage(projectId: int.tryParse(id) ?? 0);
      }),

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
