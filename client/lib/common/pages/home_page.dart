import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/widgets/agendas/agenda_future_widget.dart';
import 'package:qfqq/common/widgets/decisions/decision_responsabilities_widget.dart';
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
        children: [
          SidebarWidget(),
          Expanded(
            child: Column(
              children: [
                Expanded(child: buildMainContent(context)),
                buildMainButtons(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMainButtons(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildButton(context, 'Start Meeting', '/meeting-selection'),
          buildButton(context, S.of(context).homePageCreateAgenda, '/agenda'),
          buildButton(context, S.of(context).homePageUpdateAgenda, '/agendas'),
          buildButton(context, 'Projects', '/projects'),
        ],
      ),
    );
  }

  Widget buildMainContent(BuildContext context) {
    return SizedBox.expand(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildDecisionsContent(context),
          buildMeetingsContent(context),
        ],
      ),
    );
  }

  Widget buildButton(BuildContext context, String text, String path) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () => context.go(path),
        style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
        child: Text(text),
      ),
    );
  }

// TODO: When the user logs in, directly send the first page of it's meetings and decisions
  Widget buildDecisionsContent(BuildContext context) {
    return buildContentCard(context, 'Responsabilities', DecisionResponsabilitiesWidget());
  }

  Widget buildMeetingsContent(BuildContext context) {
    return buildContentCard(context, 'Future Meetings', AgendaFuturesWidget());
  }

  Widget buildContentCard(BuildContext context, String title, Widget child) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: child),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
