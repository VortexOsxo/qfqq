import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/errors/role_errors.dart';
import 'package:qfqq/common/services/organization_service.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/widgets/reusables/selection_text_fields/emails_text_field.dart';
import 'package:qfqq/common/widgets/reusables/form_filled_button.dart';
import 'package:qfqq/common/widgets/reusables/form_outlined_button.dart';
import 'package:qfqq/common/widgets/role_dropdown_menu.dart';
import 'package:qfqq/generated/l10n.dart';

final _emailFieldKey = GlobalKey<EmailsTextFieldState>();

class OrganizationInvitePage extends ConsumerStatefulWidget {
  const OrganizationInvitePage({super.key});

  @override
  ConsumerState<OrganizationInvitePage> createState() => _OrganizationInviteState();
}

class _OrganizationInviteState extends ConsumerState<OrganizationInvitePage> {
  List<String> _emails = [];
  int _roleId = 1;
  RoleErrors errors = RoleErrors();
  bool isSending = false;

  void inviteMembers() async {
    if (_emails.isEmpty) return;

    setState(() => isSending = true);
    final service = ref.read(organizationServiceProvider);
    await service.inviteMembers(_emails, _roleId);
    if (!mounted) return;

    setState(() => isSending = false);
    () => context.go('/organization');
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            loc.inviteMemberLabel,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: EmailsTextField(
                  key: _emailFieldKey,
                  hintText: loc.inviteMemberEmailHint,
                  onChanged: (value) => _emails = value,
                  error: errors.nameError,
                ),
              ),
              const SizedBox(width: 16),
              RoleDropdownMenu(
                initialRoleId: _roleId,
                valueChanged: (int? newRoleId) => _roleId = newRoleId ?? 1,
                isSmall: false,
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => _emailFieldKey.currentState?.addCurrent(),
                style: squareButtonStyle(context).copyWith(
                  minimumSize: const WidgetStatePropertyAll(Size(180, 56)),
                ),
                child: Text(loc.commonAdd),
              ),
            ],
          ),

          // TODO: Add sent invitations

          // Text(
          //   loc.inviteMemberPageCurrent,
          //   style: theme.textTheme.headlineMedium?.copyWith(
          //     fontWeight: FontWeight.bold,
          //     color: theme.primaryColor,
          //   ),
          // ),
          Expanded(child: SizedBox()),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => context.go('/organization'),
                style: squareButtonStyle(context).copyWith(
                  backgroundColor: const WidgetStatePropertyAll(Colors.white),
                  foregroundColor: WidgetStatePropertyAll(
                    Theme.of(context).primaryColor,
                  ),
                ),
                child: Text(loc.commonBack),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => inviteMembers(),
                style: squareButtonStyle(context),
                child:
                    isSending
                        ? CircularProgressIndicator()
                        : Text(loc.buttonInviteMemberSubmit),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
