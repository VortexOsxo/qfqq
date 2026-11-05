import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/decisions_provider.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/services/meeting_agenda_service.dart';

class MeetingAgendaSession extends ConsumerStatefulWidget {
  final int meetingId;
  final Widget child;

  const MeetingAgendaSession({
    super.key,
    required this.meetingId,
    required this.child,
  });

  @override
  ConsumerState<MeetingAgendaSession> createState() =>
      _MeetingAgendaSessionState();
}

class _MeetingAgendaSessionState extends ConsumerState<MeetingAgendaSession> {
  late final MeetingAgendaService _service;
  
  void _joinMeeting(int meetingId) {
    _service.joinMeeting(meetingId);
    ref.read(decisionsServiceProvider).reload(); // TODO: Optimize
  }

  void _leaveMeeting(int meetingId) =>_service.leaveMeeting(meetingId);

  @override
  void initState() {
    super.initState();
    _service = ref.read(meetingAgendaServiceProvider);
    _joinMeeting(widget.meetingId);
  }

  @override
  void didUpdateWidget(MeetingAgendaSession oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.meetingId != widget.meetingId) {
      _leaveMeeting(oldWidget.meetingId);
      _joinMeeting(widget.meetingId);
    }
  }



  @override
  void dispose() {
    _leaveMeeting(widget.meetingId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
