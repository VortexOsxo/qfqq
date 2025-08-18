import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/widgets/agendas/agenda_line_header.dart';

class AgendaFuturesWidget extends ConsumerWidget {
  const AgendaFuturesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agendas = ref.watch(meetingsAgendasProvider);

    return Column(
      children:
          agendas.map((agenda) {
            return AgendaLineHeader(agenda: agenda);
          }).toList(),
    );
  }
}
