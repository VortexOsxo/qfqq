import 'package:qfqq/common/widgets/help/help_info.dart';
import 'package:qfqq/generated/l10n.dart';

class HelpTooltipCreation {
  const HelpTooltipCreation._();

  static HelpContent meetingCreationHelp(S loc) {
    return HelpContent(
      title: loc.helpContentMeetingCreationTitle,
      tooltip: loc.helpContentMeetingCreationTooltip,
      components: [
        HelpSectionTitle(title: loc.helpContentMeetingCreationMeetingsTitle),
        HelpParagraph(text: loc.helpContentMeetingCreationMeetingsParagraph),

        HelpSectionTitle(title: loc.helpContentMeetingCreationRelevanceTitle),
        HelpBulletList(
          title: loc.helpContentMeetingCreationLimitMeetingsTitle,
          bulletPoints: [
            loc.helpContentMeetingCreationLimitMeetingsWhy,
            loc.helpContentMeetingCreationLimitMeetingsAlternatives,
            loc.helpContentMeetingCreationLimitMeetingsSpacing,
          ],
        ),
        HelpBulletList(
          title: loc.helpContentMeetingCreationLimitParticipantsTitle,
          bulletPoints: [
            loc.helpContentMeetingCreationLimitParticipantsWho,
            loc.helpContentMeetingCreationLimitParticipantsReplacement,
          ],
        ),
        HelpSectionTitle(title: loc.helpContentMeetingCreationPreparationTitle),
        HelpBulletList(
          title: loc.helpContentMeetingCreationBestTimeTitle,
          bulletPoints: [
            loc.helpContentMeetingCreationBestTimeDate,
            loc.helpContentMeetingCreationBestTimeHour,
          ],
        ),
        HelpBulletList(
          title: loc.helpContentMeetingCreationAgendaTitle,
          bulletPoints: [
            loc.helpContentMeetingCreationAgendaObjectives,
            loc.helpContentMeetingCreationAgendaTopics,
            loc.helpContentMeetingCreationAgendaTime,
            loc.helpContentMeetingCreationAgendaResponsibilities,
            loc.helpContentMeetingCreationAgendaFlexibility,
          ],
        ),
        HelpBulletList(
          title: loc.helpContentMeetingCreationOrganizationTitle,
          bulletPoints: [
            loc.helpContentMeetingCreationOrganizationRoom,
            loc.helpContentMeetingCreationOrganizationDocuments,
          ],
        ),
        HelpBulletList(
          title: loc.helpContentMeetingCreationCalendarTitle,
          bulletPoints: [
            loc.helpContentMeetingCreationCalendarDates,
            loc.helpContentMeetingCreationCalendarCommunication,
          ],
        ),
      ],
    );
  }

  static HelpContent meetingCreationModalHelp(S loc) {
    return HelpContent(
      title: loc.helpContentMeetingCreationTitle,
      tooltip: loc.helpContentMeetingCreationTooltip,
      components: [
        HelpSectionTitle(title: loc.helpContentMeetingCreationMeetingsTitle),
        HelpParagraph(text: loc.helpContentMeetingCreationMeetingsParagraph),

        HelpSectionTitle(title: loc.helpContentMeetingCreationCheckRelevanceTitle),
        HelpParagraph(text: loc.helpContentMeetingCreationCheckRelevanceParagraph1),
        HelpParagraph(text: loc.helpContentMeetingCreationCheckRelevanceParagraph2),

        HelpSectionTitle(title: loc.helpContentMeetingCreationPrepareMeetingTitle),
        HelpParagraph(text: loc.helpContentMeetingCreationPrepareMeetingParagraph),
        
      ],
    );
  }
}
