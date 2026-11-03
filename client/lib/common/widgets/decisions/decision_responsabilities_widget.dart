import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/decisions_provider.dart';
import 'package:qfqq/common/widgets/decisions/decision_line_header.dart';
import 'package:qfqq/generated/l10n.dart';

class DecisionResponsabilitiesWidget extends ConsumerWidget {
  const DecisionResponsabilitiesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decisions = ref.watch(myResponsibilitiesProvider);

    if (decisions.isEmpty) {
      return Center(child: Text(S.of(context).homePageNoResponsibilities));
    }

    return ListView.builder(
      itemCount: decisions.length,
      itemBuilder: (context, index) {
        return DecisionLineHeader(decision: decisions[index]);
      },
    );
  }
}
