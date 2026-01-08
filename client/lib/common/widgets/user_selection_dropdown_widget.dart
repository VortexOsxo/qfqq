import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/providers/users_provider.dart';

// TODO: unused
class UserSelectionDropdownWidget extends ConsumerWidget {
  final void Function(User?) onSelected;
  final String text;

  const UserSelectionDropdownWidget({super.key, required this.onSelected, required this.text});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextEditingController controller = TextEditingController();

    final users = ref.watch(usersProvider);

    final List<DropdownMenuEntry<User>> userEntries =
        users
            .map(
              (user) =>
                  DropdownMenuEntry<User>(value: user, label: user.username),
            )
            .toList();

    return Center(
      child: DropdownMenu<User>(
        controller: controller,
        enableFilter: true,
        requestFocusOnTap: true,
        leadingIcon: const Icon(Icons.search),
        label: const Text('User'),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          contentPadding: EdgeInsets.symmetric(vertical: 5.0),
        ),
        onSelected: onSelected,
        dropdownMenuEntries: userEntries,
      ),
    );
  }
}
