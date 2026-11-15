import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qfqq/generated/l10n.dart';

String formatDate(BuildContext context, DateTime? date) {
  final locale = Localizations.localeOf(context).toString();
  return DateFormat.yMMMd(locale).add_Hm().format(date ?? DateTime.now());
}

String formatDateIfPresent(BuildContext context, DateTime? date) {
  return date != null
      ? formatDate(context, date)
      : S.of(context).commonNoDateSet;
}

String formatDateDay(BuildContext context, DateTime? date) {
  final locale = Localizations.localeOf(context).toString();
  return DateFormat.yMMMd(locale).format(date ?? DateTime.now());
}

String formatDateDayIfPresent(BuildContext context, DateTime? date) {
  return date != null
      ? formatDateDay(context, date)
      : S.of(context).commonNoDateSet;
}

String? formatMeetingCountdown(BuildContext context, DateTime? meetingDate) {
  if (meetingDate == null) return null;

  final timeUntilMeeting = meetingDate.difference(DateTime.now());
  if (timeUntilMeeting.inSeconds <= 0) return null;

  final loc = S.of(context);
  final hours = (timeUntilMeeting.inMinutes / 60).round();

  if (hours >= 48) {
    return loc.meetingStartsInDays((hours / 24).round());
  }

  if (hours >= 24) {
    final remainingHours = hours - 24;
    if (remainingHours == 0) return loc.meetingStartsInOneDay;
    if (remainingHours == 1) return loc.meetingStartsInOneDayAndOneHour;
    return loc.meetingStartsInOneDayAndHours(remainingHours);
  }

  if (hours == 0) return loc.meetingStartsInLessThanHour;
  if (hours == 1) return loc.meetingStartsInOneHour;
  return loc.meetingStartsInHours(hours);
}
