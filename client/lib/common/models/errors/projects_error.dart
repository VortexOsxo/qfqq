class ProjectErrors {
  String? titleError;
  String? goalsError;
  String? supervisorErrors;

  ProjectErrors({this.titleError, this.goalsError, this.supervisorErrors});

  bool hasAny() {
    return titleError != null || goalsError != null || supervisorErrors != null;
  }

  ProjectErrors.fromJson(dynamic json) {
    if (json.containsKey('title')) {
      titleError = json['title'].toString();
    }

    if (json.containsKey('goals')) {
      goalsError = json['goals'].toString();
    }
    
    if (json.containsKey('supervisorId')) {
      supervisorErrors = json['supervisorId'].toString();
    }
  }
}
