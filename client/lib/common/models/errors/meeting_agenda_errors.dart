class MeetingAgendaErrors {
  String? titleError;
  String? reunionGoalsError;
  String? statusError;

  String? redactionDateError;
  String? reunionDateError;
  String? reunionLocationError;

  String? animatorError;
  String? participantsError;
  String? themesError;
  String? projectError;

  MeetingAgendaErrors({
    this.titleError,
    this.reunionGoalsError,
    this.statusError,
    this.redactionDateError,
    this.reunionDateError,
    this.reunionLocationError,
    this.animatorError,
    this.participantsError,
    this.themesError,
    this.projectError,
  });

  bool hasAny() {
    return titleError != null ||
        reunionGoalsError != null ||
        statusError != null ||
        redactionDateError != null ||
        reunionDateError != null ||
        reunionLocationError != null ||
        animatorError != null ||
        participantsError != null ||
        themesError != null ||
        projectError != null;
  }
}