import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/providers/users_provider.dart';

class UserTextField extends ConsumerWidget {
  final String label;
  final int initialUserId;
  final void Function(User)? onSelected;
  final String? error;

  const UserTextField({
    super.key,
    required this.label,
    this.initialUserId = 0,
    this.onSelected,
    this.error,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);
    final currentUser = users.cast<User?>().firstWhere((user) => user?.id == initialUserId, orElse: () => null);
    
    List<User> getOptions(TextEditingValue value) {
      var key = value.text.trim().toLowerCase();
      if (key.isEmpty) return const [];

      // TODO: Utilize Levenshtein distance to allow for some mistake ?
      return users
        .where((user) =>
          user.email.toLowerCase().contains(key) ||
          user.username.toLowerCase().contains(key),
        ).toList();
    }

    Widget fieldViewBuilder(
      BuildContext context,
      TextEditingController textController,
      FocusNode focusNode,
      VoidCallback onFieldSubmitted,
    ) {
      return TextField(
        controller: textController,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: label,
          errorText: error,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          prefixIcon: const Icon(Icons.person),
        ),
      );
    }

    return Autocomplete<User>(
      key: ValueKey('${currentUser?.id ?? 'no-id'}-${error ?? ''}'),
      optionsBuilder: getOptions,
      initialValue: TextEditingValue(
        text: currentUser != null ? _displayStringForOption(currentUser) : '',
      ),
      displayStringForOption: _displayStringForOption,
      onSelected: onSelected,
      fieldViewBuilder: fieldViewBuilder,
    );
  }

  static String _displayStringForOption(User user) =>
      '${user.username} - ${user.email}';

}
