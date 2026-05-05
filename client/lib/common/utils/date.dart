DateTime minDate(DateTime a, DateTime b) {
  return a.isBefore(b) ? a : b;
}