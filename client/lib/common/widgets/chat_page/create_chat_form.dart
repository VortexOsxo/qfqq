import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:qfqq/common/providers/chats_provider.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/widgets/reusables/selection_text_fields/users_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

class CreateChatForm extends ConsumerStatefulWidget {
  final Widget? chatSelector;

  const CreateChatForm({super.key, this.chatSelector});

  @override
  ConsumerState<CreateChatForm> createState() => _CreateChatFormState();
}

class _CreateChatFormState extends ConsumerState<CreateChatForm> {
  var _selectedUserIds = <int>[];
  final _nameController = TextEditingController();
  var _groupName = '';
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createChat(String name, List<int> participantIds) async {
    final messenger = ScaffoldMessenger.of(context);
    final failureMessage = S.of(context).chatCreateFailure;
    setState(() => _isCreating = true);
    try {
      final result = await ref
          .read(chatsProvider.notifier)
          .createChat(name, participantIds);

      if (result.chatId != null) {
        if (!mounted) return;
        ref.read(chatUiProvider.notifier).selectChat(result.chatId!);
      } else if (result.statusCode != 403 && messenger.mounted) {
        messenger.showSnackBar(SnackBar(content: Text(failureMessage)));
      }
    } on http.ClientException {
      // QfqqHttpClient already displays the connection error.
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final currentUserId = ref.watch(
      authStateProvider.select((state) => state.user?.id),
    );
    final isDirect = _selectedUserIds.length == 1;
    final trimmedName = _nameController.text.trim();
    final nameIsTooLong = trimmedName.runes.length > 400;
    final canCreate =
        !_isCreating &&
        currentUserId != null &&
        _selectedUserIds.isNotEmpty &&
        trimmedName.isNotEmpty &&
        !nameIsTooLong;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: TextField(
            controller: _nameController,
            readOnly: isDirect,
            maxLength: 400,
            decoration: InputDecoration(
              labelText: loc.chatNameLabel,
              hintText: loc.chatCreateNew,
              errorText: nameIsTooLong ? loc.chatNameTooLong : null,
              counterText: '',
              isDense: true,
            ),
            onChanged: (value) => setState(() => _groupName = value),
          ),
        ),
        const Divider(height: 1),
        if (widget.chatSelector != null) ...[
          widget.chatSelector!,
          const Divider(height: 1),
        ],
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    UsersTextField(
                      label: loc.chatParticipantsLabel,
                      excludedUserIds: [
                        if (currentUserId != null) currentUserId,
                      ],
                      onChanged:
                          (users) => setState(() {
                            final wasDirect = _selectedUserIds.length == 1;
                            _selectedUserIds =
                                users.map((user) => user.id).toList();
                            if (users.length == 1) {
                              if (!wasDirect) _groupName = _nameController.text;
                              _nameController.text = users.single.displayName;
                            } else if (wasDirect) {
                              _nameController.text = _groupName;
                            }
                          }),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      children: [
                        TextButton(
                          onPressed:
                              () => ref
                                  .read(chatUiProvider.notifier)
                                  .setShowCreation(false),
                          child: Text(loc.commonCancel),
                        ),
                        FilledButton(
                          onPressed:
                              canCreate
                                  ? () =>
                                      _createChat(trimmedName, _selectedUserIds)
                                  : null,
                          child: Text(loc.commonCreate),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
