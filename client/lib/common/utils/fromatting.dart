import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatDate(BuildContext context, DateTime? date) {
   final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(
      locale,
    ).add_Hm().format(date ?? DateTime.now());
}