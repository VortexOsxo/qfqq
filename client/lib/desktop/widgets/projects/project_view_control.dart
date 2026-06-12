import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/permissions.dart';
import 'package:qfqq/common/view_models/project_view_page_view_model.dart';
import 'package:qfqq/common/widgets/permission_required.dart';
import 'package:qfqq/generated/l10n.dart';

class ProjectViewControl extends ConsumerWidget {
  final ProjectViewPageViewModelState vm;

  const ProjectViewControl({super.key, required this.vm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton(
          onPressed: vm.goToModify,
          child: Text(loc.commonModify),
        ),
        PermissionRequired(
          neededPermissions: Permissions(canDelete: true),
          child: TextButton(
            onPressed: vm.deleteProject,
            child: Text(loc.commonDelete),
          ),
        ),
      ],
    );
  }
}
