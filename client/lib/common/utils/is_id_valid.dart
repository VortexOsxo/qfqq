bool isIdValid(int? id) {
  return id != null && id >= 0;
}

bool isIdValidAndEqual(int? id, int? targetId) {
  return isIdValid(id) && id == targetId;
}
