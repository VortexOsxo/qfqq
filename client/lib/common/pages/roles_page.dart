import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/roles_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/providers/users_roles_provider.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/utils/string.dart';
import 'package:qfqq/common/widgets/reusables/default_dropdown_menu.dart';
import 'package:qfqq/common/widgets/role_creation_modal.dart';
import 'package:qfqq/generated/l10n.dart';

// Inpirations
/*
  https://dribbble.com/shots/10591013-Admin-Roles-Management
  https://dribbble.com/shots/25113156-Invite-team-members
  https://dribbble.com/shots/13944985-QuickBooks-Online-User-Management-I
*/

class RolesPage extends ConsumerWidget {
  const RolesPage({super.key});

  void deleteRole(WidgetRef ref, int roleId) {
    final service = ref.read(rolesProvider.notifier);
    service.deleteRole(roleId);
  }

  void updateRolePermission(
    WidgetRef ref,
    int id,
    String permission,
    bool value,
  ) {
    final service = ref.read(rolesProvider.notifier);
    service.updateRole(id, permission, value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var permissionTable = Card(child: _permissionTable(context, ref));

    return Padding(
      padding: EdgeInsetsGeometry.all(16),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (_) => RoleCreationModal(),
                );
              },
              style: squareButtonStyle(context),
              child: Text(S.of(context).buttonCreateRole),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: permissionTable),
        ],
      ),
    );
  }

  Widget _permissionTable(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);
    var users = ref.watch(usersProvider);
    var roles = ref.watch(rolesProvider);

    final List<DropdownMenuEntry<int?>> menuEntries = UnmodifiableListView([
      ...roles.map(
        (role) => DropdownMenuEntry<int?>(
          value: role.id,
          label: '${S.of(context).commonRole}: ${role.name}',
        ),
      ),
    ]);

    return DataTable(
      columns: [
        DataColumn(label: Text(loc.attributeFirstName)),
        DataColumn(label: Text(loc.attributeLastName)),
        DataColumn(label: Text(loc.attributeEmail)),
        DataColumn(label: Text('Role')),
      ],
      rows:
          users.map((user) {
            var userRole = ref.watch(userRoleByIdProvider(user.id));
            // var roleName = userRole?.roleName ?? 'Default';
            var roleId = userRole?.roleId ?? 0;


            return DataRow(
              cells: [
                DataCell(Text(capitalize(user.firstName))),
                DataCell(Text(capitalize(user.lastName))),
                DataCell(Text(capitalize(user.email))),
                // DataCell(Text(capitalize(roleName))),

                DataCell(
                  DefaultDropdownMenu<int?>(
                    initialSelection: roleId,
                    onSelected: (int? newRoleId) {
                      if (newRoleId == null) return;
                      ref
                          .read(usersRolesProvider.notifier)
                          .updateUserRole(user.id, newRoleId);
                    },
                    entries: menuEntries,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    constraints: const BoxConstraints(maxHeight: 36),
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }
}
