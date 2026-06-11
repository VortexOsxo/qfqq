import 'package:flutter/material.dart';
import 'package:qfqq/common/templates/button_template.dart';
import 'package:qfqq/common/widgets/page_content/home_page_content.dart';
import 'package:qfqq/generated/l10n.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: const HomePageContent()),
        buildNavButtonTemplate(
            context,
            S.of(context).homePageProjectButton,
            '/projects/creation',
          ),
        buildNavButtonTemplate(
            context,
            S.of(context).homePageMeetingButton,
            '/agendas/creation',
          ),
      ],
    );
  }
}
