import 'package:flutter/material.dart';
import 'package:qfqq/common/widgets/reusables/form_filled_button.dart';
import 'package:qfqq/common/widgets/reusables/form_outlined_button.dart';
import 'package:qfqq/common/widgets/reusables/selection_text_fields/users_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/services/reports_service.dart';

class ReportSendModal extends ConsumerStatefulWidget {
  final String pdfUrl;

  const ReportSendModal({super.key, required this.pdfUrl});

  @override
  ConsumerState<ReportSendModal> createState() => _ReportSendModalState();
}

class _ReportSendModalState extends ConsumerState<ReportSendModal> {
  List<String> emails = [];

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return AlertDialog(
      title: Text(loc.reportSendModalTitle),
      content: SizedBox(
        width: 600,
        height: 200,
        child: SingleChildScrollView(
          child: UsersTextField(
            label: loc.reportSendModalRecipient,
            onChanged: (users) {
              setState(() {
                emails = users.map((e) => e.email).toList();
              });
            },
          ),
        ),
      ),
      actions: [
        FormOutlinedButton(
          text: loc.commonCancel,
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        FormFilledButton(
          text: loc.reportSendModalSend,
          onPressed: emails.isEmpty ? null : () async {
            final success = await ref.read(reportsServiceProvider).sendReport(widget.pdfUrl, emails);
            if (!context.mounted) return;
            
            if (success) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.reportSendModalSuccess)),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.errorUnknown),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
