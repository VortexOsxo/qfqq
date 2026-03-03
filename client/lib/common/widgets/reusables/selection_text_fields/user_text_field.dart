import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/widgets/reusables/selection_text_fields/utils.dart';

class UserTextField extends ConsumerStatefulWidget {
  final String label;
  final int initialUserId;
  final void Function(User)? onSelected;
  final String? error;
  final bool resetOnSelect;

  const UserTextField({
    super.key,
    required this.label,
    this.initialUserId = 0,
    this.onSelected,
    this.resetOnSelect = false,
    this.error,
  });

  @override
  ConsumerState<UserTextField> createState() => _UserTextFieldState();
}

class _UserTextFieldState extends ConsumerState<UserTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback(_loadInitialUser);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersProvider);

    return RawAutocomplete<User>(
      textEditingController: _controller,
      focusNode: _focusNode,
      displayStringForOption: _displayStringForOption,

      optionsBuilder: (TextEditingValue value) {
        final key = value.text.trim().toLowerCase();
        if (key.isEmpty) return users;

        return users
            .where(
              (user) =>
                  user.email.toLowerCase().contains(key) ||
                  user.username.toLowerCase().contains(key),
            )
            .toList();
      },

      fieldViewBuilder: defaultFieldViewBuilder(
        widget.label,
        widget.error,
        Icons.person,
      ),

      optionsViewBuilder: defaultOptionsViewBuilder<User>(
        (user, callback) => ListTile(
          title: Text(user.username),
          subtitle: Text(user.email),
          onTap: callback,
        ),
      ),

      onSelected: (User user) {
        widget.onSelected?.call(user);
        if (widget.resetOnSelect) {
          _controller.clear();
        }
      },
    );
  }

  void _loadInitialUser(Duration? _) {
    final currentUser = ref.read(userByIdProvider(widget.initialUserId));

    if (currentUser != null && _controller.text.isEmpty) {
      _controller.text = _displayStringForOption(currentUser);
    }
  }

  static String _displayStringForOption(User user) =>
      '${user.username} - ${user.email}';
}
