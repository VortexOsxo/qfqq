import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/providers/roles_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/providers/users_roles_provider.dart';
import 'package:qfqq/common/services/modal_service.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/utils/role.dart';
import 'package:qfqq/common/utils/string.dart';
import 'package:qfqq/common/widgets/role_creation_modal.dart';
import 'package:qfqq/common/widgets/dropdowns/role_dropdown_menu.dart';
import 'package:qfqq/generated/l10n.dart';

// Inpirations
/*
  https://dribbble.com/shots/10591013-Admin-Roles-Management
  https://dribbble.com/shots/25113156-Invite-team-members
  https://dribbble.com/shots/13944985-QuickBooks-Online-User-Management-I
*/

class OrganizationPage extends StatelessWidget {
  const OrganizationPage({super.key});

  @override
  Widget build(BuildContext context) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Card(
            margin: EdgeInsets.zero,
            child: SingleChildScrollView(
              child: DataTable(
                columns: [
                  DataColumn(label: Text(loc.attributeFirstName)),
                  DataColumn(label: Text(loc.attributeLastName)),
                  DataColumn(label: Text(loc.attributeEmail)),
                  DataColumn(label: Text(loc.commonRole)),
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
                            RoleDropdownMenu(
                              initialRoleId: roleId,
                              valueChanged: (int? newRoleId) async {
                                if (newRoleId == null) return;

                                final success = await ref
                                    .read(usersRolesProvider.notifier)
                                    .updateUserRole(user.id, newRoleId);

                                if (!success && context.mounted) {
                                  ModalService.showInformation(
                                    context: context,
                                    title: loc.selfLockoutErrorTitle,
                                    message: loc.selfLockoutErrorMessage,
                                  );
                                }
                              },
                              isSmall: true,
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
          onPressed: () => context.go('/organization/invite'),
          style: squareButtonStyle(context),
          child: Text(loc.buttonInvitePeople),
        ),
      ],
    );
  }
}

class RolesTab extends ConsumerWidget {
  const RolesTab({super.key});

  void deleteRole(BuildContext context, WidgetRef ref, int roleId) async {
    final loc = S.of(context);

    final confirmed = await ModalService.showConfirmation(
      context: context,
      title: loc.roleDeleteTitle,
      message: loc.roleDeleteMessage,
      confirmLabel: loc.roleDeleteConfirm,
    );
    if (!confirmed) return;

    final service = ref.read(rolesProvider.notifier);
    final success = await service.deleteRole(roleId);

    if (!success && context.mounted) {
      ModalService.showInformation(
        context: context,
        title: loc.roleDeleteErrorTitle,
        message: loc.roleDeleteErrorMessage,
      );
    }
  }

  void updateRolePermission(
    BuildContext context,
    WidgetRef ref,
    int id,
    String permission,
    bool value,
  ) async {
    final loc = S.of(context);

    final success = await ref.read(rolesProvider.notifier).updateRole(id, permission, value);

    if (!success && context.mounted) {
      ModalService.showInformation(
        context: context,
        title: loc.selfLockoutErrorTitle,
        message: loc.selfLockoutErrorMessage,
      );
    }
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
                  DataColumn(label: Text(loc.roleContribute), tooltip: loc.roleContributeTooltip),
                  DataColumn(label: Text(loc.roleDeleteContent), tooltip: loc.roleDeleteContentTooltip),
                  DataColumn(label: Text(loc.roleManageTeam), tooltip: loc.roleManageTeamTooltip),
                  DataColumn(label: Text('${loc.commonAction}s')),
                ],
                rows:
                    roles.map((role) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(formatRoleName(role)),
                          ),
                          _checkboxDataCell(context, ref, role.id, role.contribute, "contribute"),
                          _checkboxDataCell(context, ref, role.id, role.deleteContent, "deleteContent"),
                          _checkboxDataCell(context, ref, role.id, role.manageTeam, "manageTeam"),
                          DataCell(
                            Row(
                              children: [
                                if (role.id != 1 && role.id != 2)
                                  IconButton(
                                    onPressed: () => deleteRole(context, ref, role.id),
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
    BuildContext context,
    WidgetRef ref,
    int id,
    bool currentValue,
    String permission,
  ) {
    return DataCell(
      Checkbox(
        value: currentValue,
        onChanged: (value) {
          updateRolePermission(context, ref, id, permission, value ?? !currentValue);
        },
      ),
    );
  }
}
