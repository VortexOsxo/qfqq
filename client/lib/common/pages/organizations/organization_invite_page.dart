import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/providers/invitations_provider.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/widgets/invitations_list_widget.dart';
import 'package:qfqq/common/widgets/reusables/default_text_field.dart';
import 'package:qfqq/common/widgets/role_dropdown_menu.dart';
import 'package:qfqq/generated/l10n.dart';

class OrganizationInvitePage extends ConsumerStatefulWidget {
  const OrganizationInvitePage({super.key});

  @override
  ConsumerState<OrganizationInvitePage> createState() =>
      _OrganizationInviteState();
}

class _OrganizationInviteState extends ConsumerState<OrganizationInvitePage> {
  late final TextEditingController _emailController;
  
  String _email = '';
  int _roleId = 1;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: _email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void inviteMember() async {
    if (_email.isEmpty) return; // TODO: better validation ?

    final email = _email;

    setState(() {
      _email = "";
      _emailController.clear();
    });

    final service = ref.read(invitationsProvider.notifier);
    await service.addInvitation(email, _roleId);
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
                child: DefaultTextField(
                  controller: _emailController,
                  hintText: loc.inviteMemberEmailHint,
                  onChanged: (v) => _email = v,
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
                onPressed: inviteMember,
                style: squareButtonStyle(context).copyWith(
                  minimumSize: const WidgetStatePropertyAll(Size(180, 56)),
                ),
                child: Text(loc.buttonInviteMemberSubmit),
              ),
            ],
          ),

          SizedBox(height: 24),

          Text(
            loc.inviteMemberPageCurrent,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          Expanded(child: InvitationsListWidget()),
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
        ],
      ),
    );
  }
}
