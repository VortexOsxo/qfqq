import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/pages/not_found_page.dart';
import 'package:qfqq/common/pages/user_pages/organization_links_page.dart';
import 'package:qfqq/common/providers/navigator_key.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/utils/route_titles.dart';
import 'package:qfqq/common/widgets/scaffolds/auth_page_scaffold.dart';

final allowedRoutesNoAccount = {'/login', '/signup', '/forgotten-password'};
final allowedRoutesNoOrg = allowedRoutesNoAccount.union({
  '/organizations/links',
});

String? redirect(Ref ref, BuildContext context, GoRouterState state) {
  final authState = ref.read(authStateProvider);
  final loc = state.matchedLocation;

  if (!authState.isAuthenticated && !allowedRoutesNoAccount.contains(loc)) {
    return '/login';
  }

  if (!authState.hasOrg && !allowedRoutesNoOrg.contains(loc)) {
    return '/organizations/links';
  }

  return null;
}

typedef BuilderType = Widget Function(BuildContext, GoRouterState);
typedef OnExitType = FutureOr<bool> Function(BuildContext, GoRouterState);

class RoutePlan {
  final String path;
  final BuilderType builder;
  final OnExitType? onExit;

  const RoutePlan(this.path, this.builder, [this.onExit]);
}

abstract class RouterBuilder {

  GoRouter buildRouter(Ref ref) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: '/login',
      errorBuilder: (context, state) => const NotFoundPage(),
      redirect: (context, state) => redirect(ref, context, state),
      routes: [
        buildMainShellRoute(),
        buildAuthShellRoute(),

        ...[
          for (final route in otherRoutes())
            routeBuilder(route.path, route.builder, route.onExit),
        ],
      ],
    );
  }

  ShellRoute buildMainShellRoute() {
    final routes = <RouteBase>[
      for (final route in mainShellRoutes())
        routeBuilder(route.path, route.builder, route.onExit),
    ];

    return ShellRoute(builder: mainShellBuilder, routes: routes);
  }

  Widget mainShellBuilder(BuildContext context, GoRouterState state, Widget child);

  GoRoute routeBuilder(String path, BuilderType builder, [OnExitType? onExit]) {
    return GoRoute(
      path: path,
      onExit: onExit,
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: builder(context, state),
      ),
    );
  }

  List<RoutePlan> mainShellRoutes();

  ShellRoute buildAuthShellRoute() {
    final routes = <RouteBase>[
      for (final route in authShellRoutes())
        routeBuilder(route.path, route.builder, route.onExit),
    ];

    return ShellRoute(builder: _authShellBuilder, routes: routes);
  }

  Widget _authShellBuilder(BuildContext context, GoRouterState state, Widget child) {
    final title = getTitleForRoute(context, state);
    return authPageScaffold(context, child, title: title);
  }

  List<RoutePlan> authShellRoutes();

  List<RoutePlan> otherRoutes() {
    return [
      RoutePlan('/organizations/links', (c, s) => const OrganizationLinksPage())
    ];
  }

}