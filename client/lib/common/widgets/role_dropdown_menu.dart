import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/roles_provider.dart';
import 'package:qfqq/common/utils/string.dart';
import 'package:qfqq/common/widgets/reusables/default_dropdown_menu.dart';
import 'package:qfqq/generated/l10n.dart';

class RoleDropdownMenu extends ConsumerWidget {
  final int initialRoleId;
  final ValueChanged<int?> valueChanged;
  final bool isSmall;

  const RoleDropdownMenu({super.key, required this.initialRoleId, required this.valueChanged, required this.isSmall});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);

    var roles = ref.watch(rolesProvider);

    final List<DropdownMenuEntry<int?>> menuEntries = UnmodifiableListView([
      ...roles.map(
        (role) => DropdownMenuEntry<int?>(
          value: role.id,
          label:
              '${loc.commonRole}: ${role.id == 1 ? loc.roleNameDefault : capitalize(role.name)}',
        ),
      ),
    ]);

    return DefaultDropdownMenu<int?>(
      initialSelection: initialRoleId,
      onSelected: (int? value) => valueChanged(value),
      entries: menuEntries,
      isDense: isSmall,
      contentPadding: isSmall ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8) : null,
      constraints: isSmall ? const BoxConstraints(maxHeight: 36) : null,
      textStyle: isSmall ? const TextStyle(fontSize: 14) : null,
    );
  }
}
