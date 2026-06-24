class MeetingReview {
  bool anonymous = true;

  int objective = -1;
  int smoothRunning = -1;
  int preparation = -1;
  int length = -1;
  int respect = -1;

  String comments = "";

  MeetingReview();

  factory MeetingReview.fromJson(Map<String, dynamic> json) {
    return MeetingReview()
      ..anonymous = json['anonymous'] as bool? ?? true
      ..objective = json['objective'] as int? ?? -1
      ..smoothRunning = json['smoothRunning'] as int? ?? -1
      ..preparation = json['preparation'] as int? ?? -1
      ..length = json['length'] as int? ?? -1
      ..respect = json['respect'] as int? ?? -1
      ..comments = json['comments'] as String? ?? "";
  }

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
