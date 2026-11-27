import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:qfqq/common/providers/chats_provider.dart';
import 'package:qfqq/common/widgets/reusables/selection_text_fields/users_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

class CreateChatForm extends ConsumerStatefulWidget {
  const CreateChatForm({super.key});

  @override
  ConsumerState<CreateChatForm> createState() => _CreateChatFormState();
}

class _CreateChatFormState extends ConsumerState<CreateChatForm> {
  var _selectedUserIds = <int>[];
  var _chatName = '';
  bool _isCreating = false;

  Future<void> _createChat(String name, List<int> participantIds) async {
    final messenger = ScaffoldMessenger.of(context);
    final failureMessage = S.of(context).chatCreateFailure;
    setState(() => _isCreating = true);
    try {
      final statusCode = await ref
          .read(chatsProvider.notifier)
          .createChat(name, participantIds);

      if (statusCode == 201) {
        if (!mounted) return;
        final chats = ref.read(chatsProvider);
        if (chats.isNotEmpty) {
          ref.read(chatUiProvider.notifier).selectChat(chats.last.id);
        }
      } else if (statusCode != 403 && messenger.mounted) {
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
    final trimmedName = _chatName.trim();
    final nameIsTooLong = trimmedName.runes.length > 400;
    final canCreate =
        !_isCreating &&
        _selectedUserIds.isNotEmpty &&
        trimmedName.isNotEmpty &&
        !nameIsTooLong;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                maxLength: 400,
                decoration: InputDecoration(
                  labelText: loc.chatNameLabel,
                  errorText: nameIsTooLong ? loc.chatNameTooLong : null,
                ),
                onChanged: (value) => setState(() => _chatName = value),
              ),
              const SizedBox(height: 12),
              UsersTextField(
                label: loc.chatParticipantsLabel,
                onChanged:
                    (users) => setState(
                      () =>
                          _selectedUserIds =
                              users.map((user) => user.id).toList(),
                    ),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () => ref.read(chatUiProvider.notifier).setShowCreation(false),
                    child: Text(loc.commonCancel),
                  ),
                  FilledButton(
                    onPressed:
                        canCreate
                            ? () => _createChat(trimmedName, _selectedUserIds)
                            : null,
                    child: Text(loc.commonCreate),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
