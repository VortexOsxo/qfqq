import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/templates/page_template.dart';
import 'package:qfqq/generated/l10n.dart';
import 'package:intl/intl.dart';


class AgendasListPage extends ConsumerWidget {
  const AgendasListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   final agendas = ref.watch(meetingsAgendasProvider);

    String title = S.of(context).agendasListPageTitle;
    Widget content = _buildAgendasList(context, agendas);

    return buildPageTemplate(context, content, title);
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
            onTap: () => context.go('/agendas/${agenda.id}'),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(BuildContext context, MeetingAgendaStatus status) {
    Color color;
    String label;

    switch (status) {
      case MeetingAgendaStatus.draft:
        color = Colors.orange;
        label = S.of(context).agendaStatusDraft;
        break;
      case MeetingAgendaStatus.planned:
        color = Colors.blue;
        label = S.of(context).agendaStatusPlanned;
        break;
      case MeetingAgendaStatus.completed:
        color = Colors.green;
        label = S.of(context).agendaStatusCompleted;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
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