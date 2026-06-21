class MeetingReview {
  bool anonymous = true;

  int objective = -1;
  int smoothRunning = -1;
  int preparation = -1;
  int length = -1;
  int respect = -1;

  String comments = "";

  Map<String, dynamic> toJson() {
    return {
      'anonymous': anonymous,
      'objective': objective,
      'smoothRunning': smoothRunning,
      'preparation': preparation,
      'length': length,
      'respect': respect,
      'comments': comments,
    };
  }
}
