import 'package:go_router/go_router.dart';
import 'package:qfqq/common/pages/home_page.dart';
import 'package:qfqq/common/pages/agenda_list_page.dart';

final GoRouter mobileRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/agendas',
      builder: (context, state) => const AgendasListPage(),
    ),
  ],
);