import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/templates/button_template.dart';
import 'package:qfqq/common/templates/page_template.dart';
import 'package:qfqq/common/widgets/agendas/agenda_future_widget.dart';
import 'package:qfqq/common/widgets/decisions/decision_responsabilities_widget.dart';
import 'package:qfqq/generated/l10n.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    String title = S.of(context).homePageTitle;
    Widget content = Column(
      children: [
        Expanded(child: buildMainContent(context)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildNavButtonTemplate(
              context,
              S.of(context).buttonCreateAgenda,
              '/agenda',
            ),
            buildNavButtonTemplate(
              context,
              S.of(context).buttonCreateProject,
              '/project/creation',
            ),
          ],
        ),
      ],
    );
    return buildPageTemplate(context, content, title);
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

  // TODO: When the user logs in, directly send the first page of it's meetings and decisions
  Widget buildDecisionsContent(BuildContext context) {
    final loc = S.of(context);

    return buildContentCard(
      context,
      loc.homePageResponsabilities,
      DecisionResponsabilitiesWidget(),
      '/decisions',
    );
  }

  Widget buildMeetingsContent(BuildContext context) {
    final loc = S.of(context);

    return buildContentCard(
      context,
      loc.homePageFutureMeetings,
      AgendaFuturesWidget(),
      '/agendas',
    );
  }

  Widget buildContentCard(
    BuildContext context,
    String title,
    Widget child,
    String route,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                Expanded(
                  child: TextButton(
                    child: Text(S.of(context).commonViewAll),
                    onPressed: () => context.go(route),
                  ),
                ),
              ],
            ),
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
