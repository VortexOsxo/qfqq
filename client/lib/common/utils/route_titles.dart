import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/generated/l10n.dart';

String? getTitleForRoute(BuildContext context, GoRouterState state) {
  final loc = S.of(context);
  final fullPath = state.fullPath;

  if (fullPath == null) return null;

  switch (fullPath) {
    case '/':
      return loc.homePageTitle;
    case '/agendas/creation':
      final agenda = state.extra as MeetingAgenda?;
      return agenda == null
          ? '${loc.agendaPageTitleAppBar} - ${loc.commonCreate}'
          : '${loc.agendaPageTitleAppBar} - ${loc.commonUpdate}';
    case '/agendas':
      return loc.agendasListPageTitle;
    case '/agendas/:id':
      return loc.agendaPageTitleAppBar;
    case '/decisions':
      return loc.decisionsListPageTitle;
    case '/decisions/report':
      return loc.decisionsReportPageTitle;
    case '/decisions/:id':
      return loc.decisionViewPageTitle;
    case '/projects':
      return loc.projectPageTitle;
    case '/projects/creation':
      return loc.projectModificationPageTitle;
    case '/projects/:id':
      return loc.projectViewPageTitle;
    case '/profile':
      return loc.profilePageTitle;
    case '/login':
      return loc.loginPageTitle;
    case '/signup':
      return loc.signupPageTitle;
    case '/organization/creation':
      return loc.organizationCreationPageTitle;
    case '/forgotten-password':
      return loc.forgottenPasswordPageTitle;
    case '/organization':
      return loc.organizationPageTitle;
    case '/organizations/links':
      return loc.organizationLinksPageTitle;
    case '/organization/invite':
      return loc.inviteMemberPageTitle;
    default:
      return null;
  }
}
