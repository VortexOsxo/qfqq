bool isDateBeforeToday(DateTime? date) {
  if (date == null) return false;

  final localDate = date.toLocal();
  final today = DateTime.now();
  return DateTime(
    localDate.year,
    localDate.month,
    localDate.day,
  ).isBefore(DateTime(today.year, today.month, today.day));
}

DateTime minDate(DateTime a, DateTime b) {
  return a.isBefore(b) ? a : b;
}
