import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/generated/l10n.dart';

String? getTitleForRoute(BuildContext context, GoRouterState state) {
  final loc = S.of(context);

  switch (state.fullPath) {
    case '/':
      return loc.homePageTitle;
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
    case '/profile':
      return loc.profilePageTitle;
    case '/login':
      return loc.loginPageTitle;
    case '/signup':
      return loc.signupPageTitle;
    case '/forgotten-password':
      return loc.forgottenPasswordPageTitle;
    default:
      return null;
  }
}
