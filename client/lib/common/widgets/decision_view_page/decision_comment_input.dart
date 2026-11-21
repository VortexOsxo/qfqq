import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/decision_events_provider.dart';
import 'package:qfqq/common/providers/decisions_provider.dart';
import 'package:qfqq/generated/l10n.dart';

class DecisionCommentInput extends ConsumerStatefulWidget {
  final int decisionId;

  const DecisionCommentInput({super.key, required this.decisionId});

  @override
  ConsumerState<DecisionCommentInput> createState() => _DecisionCommentInputState();
}

class _DecisionCommentInputState extends ConsumerState<DecisionCommentInput> {
  final _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String get comment => _commentController.text.trim();
  bool _canSubmit() => !_submitting && comment.isNotEmpty;

  Future<void> _submitComment() async {
    if (!_canSubmit()) return;

    final decisionId = widget.decisionId;

    final loc = S.of(context);
    setState(() => _submitting = true);
    try {
      final decisionsService = ref.read(decisionsServiceProvider);
      final success = await decisionsService.addComment(decisionId, comment);

      if (!mounted) return;

      // TODO: this generate a requests fetching all events from the server...
      if (success) ref.invalidate(decisionEventsProvider(decisionId));

      if (success) {
        _commentController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.decisionHistoryCommentFailed)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _commentController,
          enabled: !_submitting,
          minLines: 1,
          maxLines: 4,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: loc.decisionHistoryCommentLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed:_canSubmit() ? _submitComment : null,
          child: Text(loc.decisionHistoryCommentSubmit),
        ),
      ],
    );
  }
}
