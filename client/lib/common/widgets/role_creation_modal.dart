import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/errors/role_errors.dart';
import 'package:qfqq/common/models/role.dart';
import 'package:qfqq/common/providers/roles_provider.dart';
import 'package:qfqq/common/widgets/reusables/default_text_field.dart';
import 'package:qfqq/common/widgets/reusables/form_filled_button.dart';
import 'package:qfqq/common/widgets/reusables/form_outlined_button.dart';
import 'package:qfqq/generated/l10n.dart';

class RoleCreationModal extends ConsumerStatefulWidget {
  final Role role = Role();

  RoleCreationModal({super.key});

  @override
  ConsumerState<RoleCreationModal> createState() => _RoleCreationModal();
}

class _RoleCreationModal extends ConsumerState<RoleCreationModal> {
  RoleErrors errors = RoleErrors();
  bool isSending = false;

  void saveRole() async {
    setState(() => isSending = true);
    final service = ref.read(rolesProvider.notifier);
    final result = await service.createRole(widget.role);
    if (!mounted) return;

    setState(() => isSending = false);

    if (result.hasAny()) {
      setState(() => errors = result);
    } else {
      Navigator.pop(context);
    }
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
                hintText: loc.roleName,
                onChanged: (value) => widget.role.name = value,
                error: errors.nameError,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: Text(loc.roleContribute),
                value: widget.role.contribute,
                onChanged: (bool? value) {
                  setState(() => widget.role.contribute = value ?? false);
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                title: Text(loc.roleDeleteContent),
                value: widget.role.deleteContent,
                onChanged: (bool? value) {
                  setState(() => widget.role.deleteContent = value ?? false);
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                title: Text(loc.roleManageTeam),
                value: widget.role.manageTeam,
                onChanged: (bool? value) {
                  setState(() {
                    widget.role.manageTeam = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );

    return AlertDialog(
      title: Text(loc.buttonCreateRole),
      content: SingleChildScrollView(child: content),
      actions: [
        FormOutlinedButton(
          text: loc.commonCancel,
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        FormFilledButton(
          text: loc.commonSave,
          isSending: isSending,
          onPressed: () => saveRole(),
        ),
      ],
    );
  }
}
