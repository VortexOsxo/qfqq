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

class OrganizationPage extends ConsumerWidget {
  const OrganizationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: S.of(context).commonMembers),
                Tab(text: S.of(context).commonRoles),
              ],
            ),
            const SizedBox(height: 16),
            const Expanded(
              child: TabBarView(children: [MembersTab(), RolesTab()]),
            ),
          ],
        ),
      ),
    );
  }
}

class MembersTab extends ConsumerWidget {
  const MembersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);
    var users = ref.watch(usersProvider);
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

    return Card(
      margin: EdgeInsets.zero,
      child: SingleChildScrollView(
        child: DataTable(
          columns: [
            DataColumn(label: Text(loc.attributeFirstName)),
            DataColumn(label: Text(loc.attributeLastName)),
            DataColumn(label: Text(loc.attributeEmail)),
            const DataColumn(label: Text('Role')),
          ],
          rows:
              users.map((user) {
                var userRole = ref.watch(userRoleByIdProvider(user.id));
                var roleId = userRole?.roleId ?? 0;

                return DataRow(
                  cells: [
                    DataCell(Text(capitalize(user.firstName))),
                    DataCell(Text(capitalize(user.lastName))),
                    DataCell(Text(capitalize(user.email))),
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        constraints: const BoxConstraints(maxHeight: 36),
                        textStyle: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }
}

class RolesTab extends ConsumerWidget {
  const RolesTab({super.key});

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
    final loc = S.of(context);
    var roles = ref.watch(rolesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Card(
            margin: EdgeInsets.zero,
            child: SingleChildScrollView(
              child: DataTable(
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
                          DataCell(
                            Text(
                              role.id == 1
                                  ? loc.roleNameDefault
                                  : capitalize(role.name),
                            ),
                          ),
                          _checkboxDataCell(
                            ref,
                            role.id,
                            role.canWrite,
                            "canWrite",
                          ),
                          _checkboxDataCell(
                            ref,
                            role.id,
                            role.canDelete,
                            "canDelete",
                          ),
                          _checkboxDataCell(
                            ref,
                            role.id,
                            role.canUpdatePermissions,
                            "canUpdatePermissions",
                          ),
                          DataCell(
                            Row(
                              children: [
                                if (role.id != 1)
                                  IconButton(
                                    onPressed: () => deleteRole(ref, role.id),
                                    icon: const Icon(Icons.delete),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (_) => RoleCreationModal(),
            );
          },
          style: squareButtonStyle(context),
          child: Text(loc.buttonCreateRole),
        ),
      ],
    );
  }

  DataCell _checkboxDataCell(
    WidgetRef ref,
    int id,
    bool currentValue,
    String permission,
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
