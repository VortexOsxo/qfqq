class ProjectErrors {
  String? titleError;
  String? goalsError;
  String? supervisorError;

  ProjectErrors({this.titleError, this.goalsError, this.supervisorError});

  bool hasAny() {
    return titleError != null || goalsError != null || supervisorError != null;
  }

  ProjectErrors.fromJson(dynamic json) {
    if (json == null || json is! Map) return;

    if (json.containsKey('title')) {
      titleError = json['title'].toString();
    }

    if (json.containsKey('goals')) {
      goalsError = json['goals'].toString();
    }
    
    if (json.containsKey('supervisorId')) {
      supervisorError = json['supervisorId'].toString();
    }
  }
}
