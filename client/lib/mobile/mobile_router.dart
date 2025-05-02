import 'package:go_router/go_router.dart';
import 'package:qfqq/common/pages/home_page.dart';
import 'package:qfqq/common/pages/about_page.dart';

final GoRouter mobileRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutPage(),
    ),
  ],
);