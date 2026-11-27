import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/chats_provider.dart';
import 'package:qfqq/generated/l10n.dart';

class ChatMessageInput extends ConsumerStatefulWidget {
  const ChatMessageInput({super.key});

  @override
  ConsumerState<ChatMessageInput> createState() => _ChatMessageInputState();
}

class _ChatMessageInputState extends ConsumerState<ChatMessageInput> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final chatId = ref.read(chatUiProvider).chatId;
    final content = _controller.text.trim();
    if (chatId == null || content.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      final statusCode = await ref
          .read(chatsProvider.notifier)
          .sendMessage(chatId, content);
      if (!mounted) return;

      if (statusCode == 201) {
        _controller.clear();
        ref.invalidate(chatMessagesProvider(chatId));
      } else if (statusCode != 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).chatMessageSendFailure)),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final canSend = !_sending && _controller.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              readOnly: _sending,
              onChanged: (_) => setState(() {}),
              onEditingComplete: () {},
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: loc.chatMessageHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            tooltip: loc.chatMessageSend,
            onPressed: canSend ? _send : null,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
