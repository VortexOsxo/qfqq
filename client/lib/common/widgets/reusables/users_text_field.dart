import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/widgets/reusables/chip_list.dart';
import 'package:qfqq/common/widgets/reusables/user_text_field.dart';

class UsersTextField extends ConsumerStatefulWidget {
  final String label;
  final List<String> initialUsersIds;
  final void Function(List<User>)? onChanged;
  final String? error;

  const UsersTextField({
    super.key,
    required this.label,
    initialUsersIds,
    this.onChanged,
    this.error,
  }) : initialUsersIds = initialUsersIds ?? const [];

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UsersTextFieldState();
}

class _UsersTextFieldState extends ConsumerState<UsersTextField> {
  List<User> _users = [];
  bool isInitialized = false;

  void _addUser(User user) {
    if (_users.contains(user)) return;
    setState(() => _users.add(user));

    widget.onChanged?.call(_users);
  }

  void _removeUser(User user) {
    setState(() => _users.remove(user));

    widget.onChanged?.call(_users);
  }

  void _onUserSelected(User user) {
    _addUser(user);
  }

  void _initializeUsers(List<User> users) {
    if (isInitialized || users.isEmpty) return;

    var currentUsersSet = Set<String>.from(widget.initialUsersIds);
    _users = users.where((user) => currentUsersSet.contains(user.id)).toList();
    isInitialized = true;
  }

  static String _displayStringForOption(User user) =>
      '${user.username} - ${user.email}';

  @override
  Widget build(BuildContext context) {
    var users = ref.watch(usersProvider);
    
    _initializeUsers(users);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: UserTextField(
                label: widget.label,
                onSelected: _onUserSelected,
                error: widget.error,
              ),
            ),
            const SizedBox(width: 12),
            FilledButton( // TODO: Deal with that button :(
              onPressed: () {},
              style: FilledButton.styleFrom(
                minimumSize: const Size(52, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Icon(Icons.add),
            ),
          ],
        ),
        ChipList<User>(
          items: _users,
          displayString: _displayStringForOption,
          onDelete: _removeUser,
        ),
      ],
    );
  }
}
