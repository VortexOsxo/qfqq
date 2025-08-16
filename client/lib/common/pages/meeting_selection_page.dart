import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/meeting_agenda.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/widgets/common_app_bar.dart';

class MeetingSelectionPage extends ConsumerWidget {
  const MeetingSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agendas = ref.watch(meetingsAgendasProvider);

    return Scaffold(
      appBar: CommonAppBar(title: "Select a meeting"),
      body: _buildAgendasList(context, agendas),
    );
  }

  Widget _buildAgendasList(BuildContext context, List<MeetingAgenda> agendas) {
    return Center(
      child: ListView.builder(
        itemCount: agendas.length,
        itemBuilder: (context, index) => _buildAgendaItem(context, agendas[index]),
      ),
    );
  }

  Widget _buildAgendaItem(BuildContext context, MeetingAgenda agenda) {
    return Row(
      children: [
        Text(agenda.title),
        ElevatedButton(
          onPressed: () => context.go('/meeting-in-progress/${agenda.id}'),
          child: const Text('Select'),
        ),
      ],
    );
  }
}
