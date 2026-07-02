import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/decision.dart';
import 'package:qfqq/common/providers/decisions_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/services/modal_service.dart';
import 'package:qfqq/common/utils/is_id_valid.dart';
import 'package:qfqq/generated/l10n.dart';

class DecisionViewPageViewModel extends ConsumerStatefulWidget {
  final int decisionId;
  final Widget Function(DecisionViewPageViewModelState vm) builder;

  const DecisionViewPageViewModel({
    super.key,
    required this.decisionId,
    required this.builder,
  });

  @override
  ConsumerState<DecisionViewPageViewModel> createState() => DecisionViewPageViewModelState();
}

class DecisionViewPageViewModelState extends ConsumerState<DecisionViewPageViewModel> {
  
  Decision? get decision => ref.watch(decisionByIdProvider(widget.decisionId));
  bool get isInProgress => decision?.status == DecisionStatus.inProgress;

  String get responsibleName {
    final responsibleId = decision?.responsibleId;
    if (!isIdValid(responsibleId)) return '';
    return ref.watch(userByIdProvider(responsibleId!))?.displayName ?? '';
  }

  List<String> get assistantNames {
    final assistantsIds = decision?.assistantsIds ?? [];
    return assistantsIds
        .map(
          (participantId) =>
              ref.watch(userByIdProvider(participantId))?.displayName ?? '',
        )
        .toList();
  }

  bool get hasMeeting => isIdValid(decision?.meetingId);
  bool get hasProject => isIdValid(decision?.projectId);

  Future<void> markAsCompleted() =>
      ref.read(decisionsServiceProvider).updateDecisionStatus(
        widget.decisionId,
        DecisionStatus.completed,
      );

  Future<void> markAsCancelled() =>
      ref.read(decisionsServiceProvider).updateDecisionStatus(
        widget.decisionId,
        DecisionStatus.cancelled,
      );

  void goToMeeting() => context.go('/agendas/${decision?.meetingId}');
  void goToDecisions() => context.go('/decisions');

  Future<void> deleteDecision() async {
    final loc = S.of(context);

    final confirmed = await ModalService.showConfirmation(
      context: context,
      title: loc.decisionDeleteTitle,
      message: loc.decisionDeleteMessage,
      confirmLabel: loc.decisionDeleteConfirm,
      cancelLabel: loc.commonCancel,
    );

    if (!confirmed) return;

    final success = await ref
        .read(decisionsProvider.notifier)
        .deleteDecision(widget.decisionId);

    if (context.mounted && success) goToDecisions();
  }

  @override
  Widget build(BuildContext context) => widget.builder(this);
}
