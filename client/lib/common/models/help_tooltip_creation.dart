import 'package:qfqq/common/models/help_info.dart';
import 'package:qfqq/generated/l10n.dart';

class HelpTooltipCreation {
  const HelpTooltipCreation._();

  static HelpContent meetingCreationHelp(S loc) {
    return HelpContent(
      title: loc.agendaPlanningHelpTitle,
      tooltip: loc.agendaPlanningHelpTooltip,
      tips: [
        HelpInfo(
          title: loc.agendaPlanningHelpGoalTitle,
          description: loc.agendaPlanningHelpGoal,
        ),
        HelpInfo(
          title: loc.agendaPlanningHelpTopicsTitle,
          description: loc.agendaPlanningHelpTopics,
        ),
        HelpInfo(
          title: loc.agendaPlanningHelpLogisticsTitle,
          description: loc.agendaPlanningHelpLogistics,
        ),
        HelpInfo(
          title: loc.agendaPlanningHelpPeopleTitle,
          description: loc.agendaPlanningHelpPeople,
        ),
      ],
    );
  }
}
