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
