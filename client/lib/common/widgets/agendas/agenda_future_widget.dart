import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/fetcher_providers.dart';
import 'package:qfqq/common/widgets/agendas/agenda_line_header.dart';

class AgendaFuturesWidget extends ConsumerWidget {
  const AgendaFuturesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agendas = ref.watch(userMeetingsFetcherService);

    if (agendas.isLoaded) {
      return Column(
        children:
            agendas.data!.map((agenda) {
              return AgendaLineHeader(agenda: agenda);
            }).toList(),
      );
    }

    return Center(child: CircularProgressIndicator());
  }
}
