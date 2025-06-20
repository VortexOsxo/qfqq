import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/services/meeting_agenda_service.dart';
import 'package:qfqq/generated/l10n.dart';
import 'package:intl/intl.dart';

final agendasProvider = FutureProvider<List<MeetingAgenda>>((ref) async {
  final service = ref.read(meetingAgendaServiceProvider);
  return await service.getMeetingAgendas();
});

class AgendasListPage extends ConsumerWidget {
  const AgendasListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agendasAsync = ref.watch(agendasProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).agendasListPageTitle),
      ),
      body: agendasAsync.when(
        data: (agendas) => _buildAgendasList(context, agendas),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: ${error.toString()}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(agendasProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgendasList(BuildContext context, List<MeetingAgenda> agendas) {
    if (agendas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.list_alt, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              S.of(context).agendasListPageEmpty,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: agendas.length,
      itemBuilder: (context, index) {
        final agenda = agendas[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              agenda.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  S.of(context).agendasListPageRedactionDate(
                    DateFormat('MMM dd, yyyy').format(agenda.redactionDate),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                if (agenda.reunionDate != null)
                  Text(
                    S.of(context).agendasListPageReunionDate(
                      DateFormat('MMM dd, yyyy').format(agenda.reunionDate!),
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  Text(
                    S.of(context).agendasListPageNoReunionDate,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                const SizedBox(height: 8),
                _buildStatusChip(context, agenda.status),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to agenda detail/edit page
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening agenda: ${agenda.title}'),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(BuildContext context, MeetingAgendaStatus status) {
    Color color;
    String label;

    switch (status) {
      case MeetingAgendaStatus.created:
        color = Colors.orange;
        label = S.of(context).agendasListPageStatusCreated;
        break;
      case MeetingAgendaStatus.saved:
        color = Colors.blue;
        label = S.of(context).agendasListPageStatusSaved;
        break;
      case MeetingAgendaStatus.validated:
        color = Colors.green;
        label = S.of(context).agendasListPageStatusValidated;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
} 