import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/enums/id_selection_enum.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/widgets/dropdowns/default_dropdown_menu.dart';

class UserDropdownMenu extends ConsumerWidget {
  static final int _anyUserValue = IdSelection.anyId.value;
  static final int _noUserValue = IdSelection.noId.value;

  final int? initialUserId;
  final ValueChanged<int?> valueChanged;
  final String anyLabel;
  final String? noneLabel;

  const UserDropdownMenu({
    super.key,
    required this.initialUserId,
    required this.valueChanged,
    required this.anyLabel,
    this.noneLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);

    final List<DropdownMenuEntry<int>> menuEntries = UnmodifiableListView([
      DropdownMenuEntry<int>(value: _anyUserValue, label: anyLabel),
      if (noneLabel != null)
        DropdownMenuEntry<int>(value: _noUserValue, label: noneLabel!),
      ...users.map(
        (User user) =>
            DropdownMenuEntry<int>(value: user.id, label: user.displayName),
      ),
    ]);

    return DefaultDropdownMenu<int>(
      entries: menuEntries,
      initialSelection: initialUserId ?? _anyUserValue,
      onSelected:
          (value) => valueChanged(value == _anyUserValue ? null : value),
    );
  }
}
