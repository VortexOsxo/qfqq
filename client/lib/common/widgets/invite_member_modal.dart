import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/errors/role_errors.dart';
import 'package:qfqq/common/services/organization_service.dart';
import 'package:qfqq/common/widgets/reusables/selection_text_fields/emails_text_field.dart';
import 'package:qfqq/common/widgets/reusables/form_filled_button.dart';
import 'package:qfqq/common/widgets/reusables/form_outlined_button.dart';
import 'package:qfqq/generated/l10n.dart';

class InviteMemberModal extends ConsumerStatefulWidget {
  const InviteMemberModal({super.key});

  @override
  ConsumerState<InviteMemberModal> createState() => _InviteMemberModalState();
}

class _InviteMemberModalState extends ConsumerState<InviteMemberModal> {
  List<String> _emails = [];
  RoleErrors errors = RoleErrors();
  bool isSending = false;

  void inviteMembers() async {
    if (_emails.isEmpty) return;

    setState(() => isSending = true);
    final service = ref.read(organizationServiceProvider);
    await service.inviteMembers(_emails);
    if (!mounted) return;

    setState(() => isSending = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              EmailsTextField(
                hintText: loc.inviteMemberEmailHint,
                onChanged: (value) => _emails = value,
                error: errors.nameError,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );

    return AlertDialog(
      title: Text(loc.inviteMemberModalTitle),
      content: SingleChildScrollView(child: content),
      actions: [
        FormOutlinedButton(
          text: loc.commonCancel,
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        FormFilledButton(
          text: loc.buttonInviteMemberSubmit,
          isSending: isSending,
          onPressed: () => inviteMembers(),
        ),
      ],
    );
  }
}
