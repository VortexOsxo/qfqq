import 'package:flutter/material.dart';
import 'package:qfqq/common/widgets/participants_report.dart';
import 'package:qfqq/common/widgets/decisions/decisions_list_widget.dart';
import 'package:qfqq/generated/l10n.dart';

class DecisionsListPage extends StatelessWidget {
  const DecisionsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(tabs: [Tab(text: loc.commonTable), Tab(text: loc.commonReport)]),
          const Expanded(
            child: TabBarView(
              children: [DecisionsListWidget(), ParticipantsReport()],
            ),
          ),
        ],
      ),
    );
  }
}
