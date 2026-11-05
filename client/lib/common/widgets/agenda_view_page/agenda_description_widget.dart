import 'package:flutter/material.dart';
import 'package:qfqq/common/utils/fromatting.dart';
import 'package:qfqq/common/utils/get_status_ui.dart';
import 'package:qfqq/common/utils/platform.dart';
import 'package:qfqq/common/view_models/agenda_view_model.dart';
import 'package:qfqq/common/widgets/details_attribute_widget.dart';
import 'package:qfqq/common/widgets/details_list_widget.dart';
import 'package:qfqq/common/widgets/status_chip.dart';
import 'package:qfqq/generated/l10n.dart';

class AgendaDescriptionWidget extends StatelessWidget {
  final AgendaViewPageViewModelState vm;
  const AgendaDescriptionWidget({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final agenda = vm.agenda!;

    final String location = agenda.meetingLocation ?? loc.commonNoLocationSet;
    final String date = agenda.meetingDate != null ? formatDate(context, agenda.meetingDate) : loc.commonNoDateSet;

    List<Widget> locationWidgets;
    if (platformType == PlatformType.mobile) {
      locationWidgets = [
        DetailsAttributeWidget(label: loc.attributeLocationDate, value: '$location • $date'),
      ];
    } else {
      locationWidgets = [
        DetailsAttributeWidget(label: loc.attributeLocation, value: location),
        DetailsAttributeWidget(label: loc.attributeDate, value: date),
      ];
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusChip(
            statusUIData: getMeetingAgendaStatusUI(S.of(context), agenda.status),
            alignement: Alignment.centerRight,
          ),
          SizedBox(height: 8),
          DetailsAttributeWidget(
            label: loc.attributeGoals,
            value: agenda.goals ?? loc.commonNoGoalsSet,
          ),
          ...locationWidgets,
          DetailsAttributeWidget(
            label: loc.attributeAnimator,
            value: vm.animatorName.isNotEmpty
                ? vm.animatorName
                : loc.commonNoAnimatorSet,
          ),
          DetailsListWidget(
            label: loc.attributeThemes,
            emptyLabel: loc.attributeNoThemes,
            values: agenda.themes,
          ),
          const SizedBox(height: 8),
          DetailsListWidget(
            label: loc.attributeParticipants,
            emptyLabel: loc.attributeNoParticipants,
            values: vm.participantNames.isNotEmpty ? vm.participantNames : [],
          ),
        ],
      ),
    );
  }
}
