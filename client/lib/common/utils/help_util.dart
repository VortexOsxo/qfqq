import 'package:qfqq/common/widgets/help/help_info.dart';
import 'package:qfqq/generated/l10n.dart';

abstract class HelpLink {
  final S loc;

  const HelpLink({required this.loc});

  String getTitle();
  HelpContent getContent();
  HelpContent getModal();
}

class MeetingCreationHelpLink extends HelpLink {
  const MeetingCreationHelpLink({required super.loc});

  @override
  String getTitle() => loc.helpContentMeetingCreationTitle;

  @override
  HelpContent getContent() {
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

  @override
  HelpContent getModal() {
    return HelpContent(
      title: loc.helpContentMeetingCreationTitle,
      tooltip: loc.helpContentMeetingCreationTooltip,
      components: [
        HelpSectionTitle(title: loc.helpContentMeetingCreationMeetingsTitle),
        HelpParagraph(text: loc.helpContentMeetingCreationMeetingsParagraph),

        HelpSectionTitle(
          title: loc.helpContentMeetingCreationCheckRelevanceTitle,
        ),
        HelpParagraph(
          text: loc.helpContentMeetingCreationCheckRelevanceParagraph1,
        ),
        HelpParagraph(
          text: loc.helpContentMeetingCreationCheckRelevanceParagraph2,
        ),

        HelpSectionTitle(
          title: loc.helpContentMeetingCreationPrepareMeetingTitle,
        ),
        HelpParagraph(
          text: loc.helpContentMeetingCreationPrepareMeetingParagraph,
        ),
      ],
    );
  }
}

class MeetingAnimationHelpLink extends HelpLink {
  const MeetingAnimationHelpLink({required super.loc});

  @override
  String getTitle() => loc.helpContentMeetingAnimationTitle;

  @override
  HelpContent getContent() {
    return HelpContent(
      title: loc.helpContentMeetingAnimationTitle,
      tooltip: loc.helpContentMeetingAnimationTooltip,
      components: [
        HelpBulletList(
          title: loc.helpContentMeetingAnimationClimateTitle,
          bulletPoints: [
            loc.helpContentMeetingAnimationClimateWelcome,
            loc.helpContentMeetingAnimationClimateNewVisitors,
            loc.helpContentMeetingAnimationClimateRelax,
          ],
        ),
        HelpBulletList(
          title: loc.helpContentMeetingAnimationInterestTitle,
          bulletPoints: [
            loc.helpContentMeetingAnimationInterestStartOnTime,
            loc.helpContentMeetingAnimationInterestObjectives,
            loc.helpContentMeetingAnimationInterestAgenda,
            loc.helpContentMeetingAnimationInterestAdjustPoints,
            loc.helpContentMeetingAnimationInterestClarifyType,
          ],
        ),
        HelpBulletList(
          title: loc.helpContentMeetingAnimationRulesTitle,
          bulletPoints: [
            loc.helpContentMeetingAnimationRulesReprioritizeAgenda,
            loc.helpContentMeetingAnimationRulesDecisionMaking,
            loc.helpContentMeetingAnimationRulesRoles,
            loc.helpContentMeetingAnimationRulesCodeOfConduct,
            loc.helpContentMeetingAnimationRulesCommitment,
          ],
        ),
        HelpBulletList(
          title: loc.helpContentMeetingAnimationPointTitle,
          bulletPoints: [
            loc.helpContentMeetingAnimationPointLinkToGoals,
            loc.helpContentMeetingAnimationPointImportance,
            loc.helpContentMeetingAnimationPointType,
            loc.helpContentMeetingAnimationPointTiming,
          ],
        ),
        HelpBulletList(
          title: loc.helpContentMeetingAnimationExchangeTitle,
          bulletPoints: [
            loc.helpContentMeetingAnimationExchangeParticipation,
            loc.helpContentMeetingAnimationExchangeCode,
            loc.helpContentMeetingAnimationExchangeContribution,
            loc.helpContentMeetingAnimationExchangeValue,
            loc.helpContentMeetingAnimationExchangeReformulate,
            loc.helpContentMeetingAnimationExchangeSubgroups,
            loc.helpContentMeetingAnimationExchangeEssence,
          ],
        ),
        HelpBulletList(
          title: loc.helpContentMeetingAnimationConcludePointTitle,
          bulletPoints: [
            loc.helpContentMeetingAnimationConcludePointSummarize,
            loc.helpContentMeetingAnimationConcludePointWhoWhatWhen,
            loc.helpContentMeetingAnimationConcludePointCommitment,
            loc.helpContentMeetingAnimationConcludePointParticipation,
            loc.helpContentMeetingAnimationConcludePointThankAndMoveOn,
          ],
        ),
        HelpBulletList(
          title: loc.helpContentMeetingAnimationReviewObjectivesTitle,
          bulletPoints: [
            loc.helpContentMeetingAnimationReviewObjectivesReached,
            loc.helpContentMeetingAnimationReviewObjectivesCovered,
            loc.helpContentMeetingAnimationReviewObjectivesLessons,
          ],
        ),
        HelpBulletList(
          title: loc.helpContentMeetingAnimationFollowUpActionsTitle,
          bulletPoints: [
            loc.helpContentMeetingAnimationFollowUpActionsReviewDecisions,
            loc.helpContentMeetingAnimationFollowUpActionsCheckUnderstanding,
          ],
        ),
        HelpBulletList(
          title: loc.helpContentMeetingAnimationEvaluateTitle,
          bulletPoints: [
            loc.helpContentMeetingAnimationEvaluateStrengths,
            loc.helpContentMeetingAnimationEvaluateImprovements,
            loc.helpContentMeetingAnimationEvaluateHowToImprove,
            loc.helpContentMeetingAnimationEvaluateNextMeeting,
          ],
        ),
        HelpBulletList(
          title: loc.helpContentMeetingAnimationCloseTitle,
          bulletPoints: [
            loc.helpContentMeetingAnimationCloseThank,
            loc.helpContentMeetingAnimationCloseEncourage,
            loc.helpContentMeetingAnimationCloseReinforce,
            loc.helpContentMeetingAnimationCloseNextDate,
            loc.helpContentMeetingAnimationCloseRoles,
          ],
        ),
      ],
    );
  }

  @override
  HelpContent getModal() {
    return HelpContent(
      title: loc.helpContentMeetingAnimationTitle,
      tooltip: loc.helpContentMeetingAnimationTooltip,
      components: [
        HelpParagraph(text: loc.helpContentMeetingAnimationSummaryIntro),
        HelpBulletList(
          title: loc.helpContentMeetingAnimationSummaryPrepareTitle,
          bulletPoints: [
            loc.helpContentMeetingAnimationSummaryPrepareWelcome,
            loc.helpContentMeetingAnimationSummaryPrepareObjectives,
            loc.helpContentMeetingAnimationSummaryPrepareRules,
          ],
        ),
        HelpBulletList(
          title: loc.helpContentMeetingAnimationSummaryFacilitateTitle,
          bulletPoints: [
            loc.helpContentMeetingAnimationSummaryFacilitateParticipation,
            loc.helpContentMeetingAnimationSummaryFacilitateFocus,
            loc.helpContentMeetingAnimationSummaryFacilitateDecisions,
          ],
        ),
        HelpBulletList(
          title: loc.helpContentMeetingAnimationSummaryCloseTitle,
          bulletPoints: [
            loc.helpContentMeetingAnimationSummaryCloseReview,
            loc.helpContentMeetingAnimationSummaryCloseActions,
            loc.helpContentMeetingAnimationSummaryCloseEvaluate,
          ],
        ),
      ],
    );
  }
}

class MeetingParticipationHelpLink extends HelpLink {
  const MeetingParticipationHelpLink({required super.loc});

  @override
  String getTitle() => loc.helpContentMeetingParticipationTitle;

  @override
  HelpContent getContent() {
    return HelpContent(
      title: loc.helpContentMeetingParticipationTitle,
      tooltip: loc.helpContentMeetingParticipationTooltip,
      components: [
        HelpBulletList(
          title: loc.helpContentMeetingParticipationPrinciplesTitle,
          bulletPoints: [
            loc.helpContentMeetingParticipationListen,
            loc.helpContentMeetingParticipationSuspendBeliefs,
            loc.helpContentMeetingParticipationRespect,
            loc.helpContentMeetingParticipationRespectSpeech,
            loc.helpContentMeetingParticipationCalm,
            loc.helpContentMeetingParticipationAskForHelp,
          ],
        ),
      ],
    );
  }

  @override
  HelpContent getModal() {
    return HelpContent(
      title: loc.helpContentMeetingParticipationTitle,
      tooltip: loc.helpContentMeetingParticipationTooltip,
      components: [
        HelpParagraph(text: loc.helpContentMeetingParticipationSummaryIntro),
        HelpBulletList(
          title: loc.helpContentMeetingParticipationSummaryTitle,
          bulletPoints: [
            loc.helpContentMeetingParticipationListen,
            loc.helpContentMeetingParticipationSuspendBeliefs,
            loc.helpContentMeetingParticipationRespect,
            loc.helpContentMeetingParticipationCalm,
            loc.helpContentMeetingParticipationAskForHelp,
          ],
        ),
      ],
    );
  }
}

final helpLinksFactories = [
  (loc) => MeetingAnimationHelpLink(loc: loc),
  (loc) => MeetingCreationHelpLink(loc: loc),
  (loc) => MeetingParticipationHelpLink(loc: loc),
];
