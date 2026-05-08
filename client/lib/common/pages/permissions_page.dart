import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/roles_provider.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/utils/string.dart';
import 'package:qfqq/common/widgets/role_creation_modal.dart';
import 'package:qfqq/generated/l10n.dart';

// Inpirations
/*
  https://dribbble.com/shots/10591013-Admin-Roles-Management
  https://dribbble.com/shots/25113156-Invite-team-members
  https://dribbble.com/shots/13944985-QuickBooks-Online-User-Management-I
*/

class PermissionsPage extends ConsumerWidget {
  const PermissionsPage({super.key});

  void deleteRole(WidgetRef ref, int roleId) {
    final service = ref.read(rolesProvider.notifier);
    service.deleteRole(roleId);
  }

  void updateRolePermission(WidgetRef ref, int id, String permission, bool value) {
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
    var roles = ref.watch(rolesProvider);

    return DataTable(
      columns: [
        DataColumn(label: Text(loc.roleName)),
        DataColumn(label: Text(loc.roleCanWrite)),
        DataColumn(label: Text(loc.roleCanDelete)),
        DataColumn(label: Text(loc.roleCanUpdatePermissions)),
        DataColumn(label: Text('${loc.commonAction}s')),
      ],
      rows:
          roles.map((role) {
            return DataRow(
              cells: [
                DataCell(Text(capitalize(role.name))),
                _checkboxDataCell(ref, role.id, role.canWrite, "canWrite"),
                _checkboxDataCell(ref, role.id, role.canDelete, "canDelete"),
                _checkboxDataCell(ref, role.id, role.canUpdatePermissions, "canUpdatePermissions"),
                DataCell(
                  Row(
                    children: [
                      if (role.id != 1) IconButton(
                        onPressed: () => deleteRole(ref, role.id),
                        icon: Icon(Icons.delete),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }

  DataCell _checkboxDataCell(WidgetRef ref, int id, bool currentValue, String permission,
  ) {
    return DataCell(
      Checkbox(
        value: currentValue,
        onChanged: (value) {
          updateRolePermission(ref, id, permission, value ?? !currentValue);
        },
      ),
    );
  }
}
