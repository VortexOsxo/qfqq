import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/meeting_review.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/widgets/reusables/default_text_field.dart';
import 'package:qfqq/common/widgets/reusables/form_filled_button.dart';
import 'package:qfqq/common/widgets/reusables/form_outlined_button.dart';
import 'package:qfqq/common/widgets/reusables/grade_input_widget.dart';
import 'package:qfqq/generated/l10n.dart';

class MeetingReviewModal extends ConsumerStatefulWidget {
  final meetingReview = MeetingReview();
  final int meetingId = 1;

  MeetingReviewModal({super.key});

  @override
  ConsumerState<MeetingReviewModal> createState() => _MeetingReviewModalState();
}

class _MeetingReviewModalState extends ConsumerState<MeetingReviewModal> {
  bool isSending = false;

  void reviewMeeting() async {
    setState(() => isSending = true);
    ref.read(meetingsAgendasProvider.notifier);

    // final result = await service.createRole(widget.role);
    if (!mounted) return;

    setState(() => isSending = false);

    // if (result.hasAny()) {
    //   setState(() => errors = result);
    // } else {
      Navigator.pop(context);
    // }
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);


    // TODO: Add a toggle for anonymous review
    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GradeInputWidget(
                label: loc.meetingReviewObjective,
                initialValue: widget.meetingReview.objective > 0 ? widget.meetingReview.objective : null,
                onChanged: (value) => widget.meetingReview.objective = value,
              ),
              const SizedBox(height: 16),
              GradeInputWidget(
                label: loc.meetingReviewSmoothRunning,
                initialValue: widget.meetingReview.smoothRunning > 0 ? widget.meetingReview.smoothRunning : null,
                onChanged: (value) => widget.meetingReview.smoothRunning = value,
              ),
              const SizedBox(height: 16),
              GradeInputWidget(
                label: loc.meetingReviewPreparation,
                initialValue: widget.meetingReview.preparation > 0 ? widget.meetingReview.preparation : null,
                onChanged: (value) => widget.meetingReview.preparation = value,
              ),
              const SizedBox(height: 16),
              GradeInputWidget(
                label: loc.meetingReviewLength,
                initialValue: widget.meetingReview.length > 0 ? widget.meetingReview.length : null,
                onChanged: (value) => widget.meetingReview.length = value,
              ),
              const SizedBox(height: 16),
              GradeInputWidget(
                label: loc.meetingReviewRespect,
                initialValue: widget.meetingReview.respect > 0 ? widget.meetingReview.respect : null,
                onChanged: (value) => widget.meetingReview.respect = value,
              ),
              const SizedBox(height: 20),
              DefaultTextField(
                hintText: loc.meetingReviewCommentsHint,
                onChanged: (value) => widget.meetingReview.comments = value,
                maxLines: 5,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );

    return AlertDialog(
      title: Text(loc.meetingReviewTitle),
      content: SingleChildScrollView(child: content),
      actions: [
        FormOutlinedButton(
          text: loc.commonCancel,
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        FormFilledButton(
          text: loc.meetingReviewSend,
          isSending: isSending,
          onPressed: () => reviewMeeting(),
        ),
      ],
    );
  }
}
