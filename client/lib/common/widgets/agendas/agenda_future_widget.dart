import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/widgets/agendas/agenda_line_header.dart';
import 'package:qfqq/generated/l10n.dart';

class AgendaFuturesWidget extends ConsumerWidget {
  const AgendaFuturesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agendas = ref.watch(myMeetingsProvider);

    if (agendas.isEmpty) {
      return Center(child: Text(S.of(context).homePageNoFutureMeetings));
    }

    return ListView.builder(
      itemCount: agendas.length,
      itemBuilder: (context, index) {
        return AgendaLineHeader(agenda: agendas[index]);
      },
    );
  }
}
