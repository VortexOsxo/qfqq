import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/providers/decisions_provider.dart';
import 'package:qfqq/common/services/fetcher_services/base_fetcher_service.dart';
import 'package:qfqq/common/widgets/decisions/decision_line_header.dart';
import 'package:qfqq/common/widgets/sidebar_widget.dart';
import 'package:qfqq/generated/l10n.dart';
import 'package:qfqq/common/widgets/common_app_bar.dart';

class DecisionsListPage extends ConsumerWidget {
  const DecisionsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decisions = ref.watch(decisionsFetcherProvider);

    return Scaffold(
      appBar: CommonAppBar(title: S.of(context).agendasListPageTitle),
      body: Row(
        children: [
          SidebarWidget(),
          Expanded(child: _buildDecisionsList(context, decisions)),
        ],
      ),
    );
  }

  Widget _buildDecisionsList(
    BuildContext context,
    FetcherState<List<Decision>> decisions,
  ) {
    if (decisions.isLoaded) {
      return Column(
        children:
            decisions.data!.map((decision) {
              return DecisionLineHeader(decision: decision);
            }).toList(),
      );
    }

    return Center(child: CircularProgressIndicator());
  }
}
