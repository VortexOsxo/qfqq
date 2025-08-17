import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/widgets/sidebar_widget.dart';
import 'package:qfqq/generated/l10n.dart';
import 'package:qfqq/common/widgets/common_app_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: S.of(context).homePageTitle),
      body: Row(
        children: [SidebarWidget(), Expanded(child: buildMainButtons(context))],
      ),
    );
  }

  Widget buildMainButtons(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => context.go('/meeting-selection'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
            child: Text('Start Meeting'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => context.go('/agenda'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
            child: Text(S.of(context).homePageCreateAgenda),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => context.go('/agendas'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
            child: Text(S.of(context).homePageUpdateAgenda),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => context.go('/projects'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
            child: Text('Projects'),
          ),
        ],
      ),
    );
  }
}
