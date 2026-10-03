import 'package:flutter/material.dart';
import 'package:qfqq/common/view_models/decision_view_page_view_model.dart';
import 'package:qfqq/common/widgets/reusables/form_filled_button.dart';
import 'package:qfqq/common/widgets/reusables/form_outlined_button.dart';
import 'package:qfqq/generated/l10n.dart';

class DecisionsStatusControlWidget extends StatelessWidget {
  final DecisionViewPageViewModelState vm;
  const DecisionsStatusControlWidget({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    if (!(vm.isInProgress || vm.isPending)) {
      return SizedBox.shrink();
    }

    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormFilledButton(
            onPressed: vm.markAsCompleted,
            text: loc.decisionViewPageMarkAsCompleted,
          ),
          const SizedBox(height: 8),
          FormOutlinedButton(
            onPressed: vm.markAsCancelled,
            text: loc.decisionViewPageMarkAsCancelled,
          ),
          if (!vm.isPending) ...[
            const SizedBox(height: 8),
            FormOutlinedButton(
              onPressed: vm.markAsPending,
              text: loc.decisionViewPageMarkAsPending,
            ),
          ],
        ],
      ),
    );
  }
}
