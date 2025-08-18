import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/decisions_provider.dart';
import 'package:qfqq/common/widgets/decisions/decision_line_header.dart';

class DecisionResponsabilitiesWidget extends ConsumerWidget {
  const DecisionResponsabilitiesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decisions = ref.watch(decisionsProvider);

    return Column(
      children:
          decisions.map((decision) {
            return DecisionLineHeader(decision: decision);
          }).toList(),
    );
  }
}
