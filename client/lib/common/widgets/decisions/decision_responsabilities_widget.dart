import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/fetcher_providers.dart';
import 'package:qfqq/common/widgets/decisions/decision_line_header.dart';

class DecisionResponsabilitiesWidget extends ConsumerWidget {
  const DecisionResponsabilitiesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decisions = ref.watch(decisionsResponsabilitiesFetcherProvider);

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
