import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/widgets/page_content/home_page_content.dart';
import 'package:qfqq/generated/l10n.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: const HomePageContent()),
        IntrinsicWidth(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.push('/projects/creation'),
                  style: squareButtonStyle(context),
                  child: Text(S.of(context).homePageProjectButton),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.push('/agendas/creation'),
                  style: squareButtonStyle(context),
                  child: Text(S.of(context).homePageMeetingButton),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
