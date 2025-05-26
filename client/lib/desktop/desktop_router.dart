import 'package:go_router/go_router.dart';
import 'package:qfqq/common/pages/agenda_page.dart';
import 'package:qfqq/common/pages/home_page.dart';
import 'package:qfqq/common/pages/about_page.dart';
import 'package:qfqq/common/pages/login_page.dart';
import 'package:qfqq/common/pages/signup_page.dart';

final GoRouter desktopRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutPage(),
    ),
    GoRoute(
      path: '/agenda',
      builder: (context, state) => const AgendaPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupPage(),
    ),
  ],
);