import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/widgets/decisions/decisions_list_widget.dart';
import 'package:qfqq/generated/l10n.dart';

class DecisionsListPage extends StatelessWidget {
  const DecisionsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsetsGeometry.all(8),
            child: ElevatedButton(
              onPressed: () => context.go('/decisions/report'),
              style: squareButtonStyle(context),
              child: Text(loc.commonReport),
            ),
          ),
        ),
        Expanded(child: DecisionsListWidget()),
      ],
    );
  }
}
