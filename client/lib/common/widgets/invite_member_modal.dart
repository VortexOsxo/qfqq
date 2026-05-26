import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/errors/role_errors.dart';
import 'package:qfqq/common/services/organization_service.dart';
import 'package:qfqq/common/widgets/reusables/default_text_field.dart';
import 'package:qfqq/common/widgets/reusables/form_filled_button.dart';
import 'package:qfqq/common/widgets/reusables/form_outlined_button.dart';
import 'package:qfqq/generated/l10n.dart';

class InviteMemberModal extends ConsumerStatefulWidget {
  const InviteMemberModal({super.key});

  @override
  ConsumerState<InviteMemberModal> createState() => _InviteMemberModalState();
}

class _InviteMemberModalState extends ConsumerState<InviteMemberModal> {
  String email = "";
  RoleErrors errors = RoleErrors();
  bool isSending = false;

  void inviteMember() async {
    setState(() => isSending = true);
    final service = ref.read(organizationServiceProvider);
    await service.inviteMember(email);
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
              DefaultTextField(
                hintText: loc.inviteMemberEmailHint,
                onChanged: (value) => email = value,
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
          onPressed: () => inviteMember(),
        ),
      ],
    );
  }
}
