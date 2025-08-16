import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/user.dart';
import 'package:qfqq/common/providers/users_provider.dart';

class UsersSelectionDropdownWidget extends ConsumerStatefulWidget {
  final void Function(List<User>) onSelected;
  final String text;
  final List<User>? initialSelection;

  const UsersSelectionDropdownWidget({
    super.key, 
    required this.onSelected, 
    required this.text,
    this.initialSelection = const [],
  });

  @override
  ConsumerState<UsersSelectionDropdownWidget> createState() => _UsersSelectionDropdownWidgetState();
}

class _UsersSelectionDropdownWidgetState extends ConsumerState<UsersSelectionDropdownWidget> {
  List<User> selectedUsers = [];
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialSelection != null) {
      selectedUsers = List.from(widget.initialSelection!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown button
        InkWell(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: selectedUsers.isEmpty
                      ? Text(
                          widget.text,
                          style: TextStyle(color: Colors.grey[600]),
                        )
                      : Text(
                          selectedUsers.map((user) => user.username).join(', '),
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),
        ),
        
        // Dropdown content
        if (isExpanded)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final isSelected = selectedUsers.contains(user);
                
                return CheckboxListTile(
                  title: Text(user.username),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedUsers.add(user);
                      } else {
                        selectedUsers.remove(user);
                      }
                    });
                    widget.onSelected(selectedUsers);
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                );
              },
            ),
          ),
      ],
    );
  }
}
