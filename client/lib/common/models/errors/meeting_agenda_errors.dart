class MeetingAgendaErrors {
  String? titleError;
  String? goalsError;
  String? statusError;

  String? redactionDateError;
  String? meetingDateError;
  String? meetingLocationError;

  String? animatorError;
  String? participantsError;
  String? themesError;
  String? projectError;

  MeetingAgendaErrors({
    this.titleError,
    this.goalsError,
    this.statusError,
    this.redactionDateError,
    this.meetingDateError,
    this.meetingLocationError,
    this.animatorError,
    this.participantsError,
    this.themesError,
    this.projectError,
  });

  bool hasAny() {
    return titleError != null ||
        goalsError != null ||
        statusError != null ||
        redactionDateError != null ||
        meetingDateError != null ||
        meetingLocationError != null ||
        animatorError != null ||
        participantsError != null ||
        themesError != null ||
        projectError != null;
  }
}