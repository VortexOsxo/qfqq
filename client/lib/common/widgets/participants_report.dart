import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/widgets/pdf_viewer_widget.dart';
import 'package:qfqq/common/widgets/reusables/selection_text_fields/user_text_field.dart';
import 'package:qfqq/generated/l10n.dart';

class ParticipantsReport extends ConsumerStatefulWidget {
  const ParticipantsReport({super.key});

  @override
  ConsumerState<ParticipantsReport> createState() =>
      _ParticipantsReportState();
}

class _ParticipantsReportState extends ConsumerState<ParticipantsReport> {
  int? _selectedUserId;

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final users = ref.watch(usersProvider);
    final selectedUserId =
        users.any((user) => user.id == _selectedUserId)
            ? _selectedUserId
            : null;
    final pdfUrl =
        selectedUserId == null
            ? 'reports/participants'
            : 'reports/participants/$selectedUserId';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              SizedBox(
                width: 320,
                child: UserTextField(
                  key: ValueKey(selectedUserId),
                  label: loc.widgetUserLabel,
                  initialUserId: selectedUserId ?? 0,
                  onSelected: (user) {
                    setState(() => _selectedUserId = user.id);
                  },
                ),
              ),
              if (selectedUserId != null)
                IconButton(
                  tooltip: loc.participantsReportAll,
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _selectedUserId = null),
                ),
            ],
          ),
        ),
        Expanded(
          child: PdfViewerWidget(
            key: ValueKey(pdfUrl),
            pdfUrl: pdfUrl,
            pdfName:
                selectedUserId == null
                    ? 'participants-report'
                    : 'participant-report-$selectedUserId',
          ),
        ),
      ],
    );
  }
}
