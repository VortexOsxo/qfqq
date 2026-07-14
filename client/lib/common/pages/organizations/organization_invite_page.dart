import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/providers/invitations_provider.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/widgets/invitations_list_widget.dart';
import 'package:qfqq/common/widgets/reusables/default_text_field.dart';
import 'package:qfqq/common/widgets/dropdowns/role_dropdown_menu.dart';
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
  String? _emailError;
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
    if (_email.isEmpty) return;

    final email = _email;

    setState(()  => _emailError = null);

    final service = ref.read(invitationsProvider.notifier);
    final errors = await service.addInvitation(email, _roleId);
    if (!mounted) {
      return;
    }

    if (errors.emailError != null) {
      setState(() => _emailError = errors.emailError);
    } else {
      setState(() {
        _email = "";
        _emailController.clear();
      });
    }
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
          Row(
            children: [
              IconButton(
                onPressed: () => context.go('/organization'),
                icon: Icon(
                  Icons.chevron_left,
                  color: theme.primaryColor,
                  size: 32,
                ),
                tooltip: loc.commonBack,
              ),
              Text(
                loc.inviteMemberLabel,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 0),
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DefaultTextField(
                  controller: _emailController,
                  error: _emailError,
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
          ),),

          SizedBox(height: 24),

          Text(
            loc.inviteMemberPageCurrent,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          Expanded(child: InvitationsListWidget()),
        ],
      ),
    );
  }
}
