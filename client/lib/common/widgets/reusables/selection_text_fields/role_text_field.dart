import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/role.dart';
import 'package:qfqq/common/providers/roles_provider.dart';
import 'package:qfqq/common/widgets/reusables/selection_text_fields/utils.dart';

class RoleTextField extends ConsumerWidget {
  final String label;
  final int initialRoleId;
  final void Function(Role)? onSelected;
  final String? error;

  const RoleTextField({
    super.key,
    required this.label,
    this.initialRoleId = 0,
    this.onSelected,
    this.error,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(rolesProvider);
    final currentRole = ref.read(roleByIdProvider(initialRoleId));

    List<Role> getOptions(TextEditingValue value) {
      var key = value.text.trim().toLowerCase();
      if (key.isEmpty) return roles;

      return roles
          .where((role) => role.name.toLowerCase().contains(key))
          .toList();
    }

    return Autocomplete<Role>(
      key: ValueKey('${currentRole?.id ?? 'no-id'}-${error ?? ''}'),
      optionsBuilder: getOptions,
      initialValue: TextEditingValue(
        text:
            currentRole != null
                ? _displayStringForOption(currentRole)
                : '',
      ),
      displayStringForOption: _displayStringForOption,
      onSelected: onSelected,
      fieldViewBuilder: defaultFieldViewBuilder(label, error, null),
      optionsViewBuilder: defaultOptionsViewBuilder<Role>(
        (role, callback) => ListTile(title: Text(role.name), onTap: callback),
      ),
    );
  }

  static String _displayStringForOption(Role role) => role.name;
}
