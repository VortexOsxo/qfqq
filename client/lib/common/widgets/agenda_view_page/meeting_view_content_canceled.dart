import 'package:flutter/material.dart';
import 'package:qfqq/generated/l10n.dart';

class MeetingViewContentCanceled extends StatelessWidget {
  const MeetingViewContentCanceled({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(S.of(context).meetingViewContentCanceledStatus);
  }
}
