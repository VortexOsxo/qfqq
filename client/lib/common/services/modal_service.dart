import 'package:flutter/material.dart';
import 'package:qfqq/generated/l10n.dart';

class ModalService {
  ModalService._();

  static Future<bool> showConfirmation(
    BuildContext context, {
    required title,
    required message,
    String? confirmLabel,
    String? cancelLabel,
  }) async {
    confirmLabel ??= S.of(context).commonConfirm;
    cancelLabel ??= S.of(context).commonCancel;

    var result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ConfirmationDialog(title, message, confirmLabel!, cancelLabel!),
    );
    return result ?? false;
  }

  static Future<void> showInformation(
    BuildContext context, {
    required String title,
    required String message,
    String? closeLabel,
  }) {
    closeLabel ??= S.of(context).commonClose;
    return showDialog<void>(
      context: context,
      builder: (_) => _InformationDialog(title, message, closeLabel!),
    );
  }
}

class _ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  const _ConfirmationDialog(
    this.title,
    this.message,
    this.confirmLabel,
    this.cancelLabel,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      title: Row(
        children: [
          Icon(
            Icons.help_outline_rounded,
            color: colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

class _InformationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String closeLabel;

  const _InformationDialog(this.title, this.message, this.closeLabel);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      title: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(closeLabel),
        ),
      ],
    );
  }
}
