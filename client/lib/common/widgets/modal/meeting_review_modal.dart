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
  final int meetingId;

  MeetingReviewModal({super.key, required this.meetingId});

  @override
  ConsumerState<MeetingReviewModal> createState() => _MeetingReviewModalState();
}

class _MeetingReviewModalState extends ConsumerState<MeetingReviewModal> {
  bool isSending = false;
  String? _objectiveError;
  String? _smoothRunningError;
  String? _preparationError;
  String? _lengthError;
  String? _respectError;

  bool _validateReview() {
    final loc = S.of(context);

    _objectiveError = MeetingReview.isValidGrade(widget.meetingReview.objective)
        ? null
        : loc.errorRequiredField;
    _smoothRunningError =
        MeetingReview.isValidGrade(widget.meetingReview.smoothRunning)
            ? null
            : loc.errorRequiredField;
    _preparationError =
        MeetingReview.isValidGrade(widget.meetingReview.preparation)
            ? null
            : loc.errorRequiredField;
    _lengthError = MeetingReview.isValidGrade(widget.meetingReview.length)
        ? null
        : loc.errorRequiredField;
    _respectError = MeetingReview.isValidGrade(widget.meetingReview.respect)
        ? null
        : loc.errorRequiredField;

    setState(() {});
    return [
      _objectiveError,
      _smoothRunningError,
      _preparationError,
      _lengthError,
      _respectError,
    ].every((error) => error == null);
  }

  void reviewMeeting() async {
    setState(() => isSending = true);
    if (!_validateReview()) {
      setState(() => isSending = false);
      return;
    }

    final service = ref.read(meetingsAgendasProvider.notifier);
    
    await service.addReview(widget.meetingId, widget.meetingReview);
    if (!mounted) return;

    setState(() => isSending = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GradeInputWidget(
              label: loc.meetingReviewObjective,
              initialValue: widget.meetingReview.objective > 0 ? widget.meetingReview.objective : null,
              errorText: _objectiveError,
              onChanged: (value) {
                setState(() => _objectiveError = null);
                widget.meetingReview.objective = value;
              },
            ),
            const SizedBox(height: 16),
            GradeInputWidget(
              label: loc.meetingReviewSmoothRunning,
              initialValue: widget.meetingReview.smoothRunning > 0 ? widget.meetingReview.smoothRunning : null,
              errorText: _smoothRunningError,
              onChanged: (value) {
                setState(() => _smoothRunningError = null);
                widget.meetingReview.smoothRunning = value;
              },
            ),
            const SizedBox(height: 16),
            GradeInputWidget(
              label: loc.meetingReviewPreparation,
              initialValue: widget.meetingReview.preparation > 0 ? widget.meetingReview.preparation : null,
              errorText: _preparationError,
              onChanged: (value) {
                setState(() => _preparationError = null);
                widget.meetingReview.preparation = value;
              },
            ),
            const SizedBox(height: 16),
            GradeInputWidget(
              label: loc.meetingReviewLength,
              initialValue: widget.meetingReview.length > 0 ? widget.meetingReview.length : null,
              errorText: _lengthError,
              onChanged: (value) {
                setState(() => _lengthError = null);
                widget.meetingReview.length = value;
              },
            ),
            const SizedBox(height: 16),
            GradeInputWidget(
              label: loc.meetingReviewRespect,
              initialValue: widget.meetingReview.respect > 0 ? widget.meetingReview.respect : null,
              errorText: _respectError,
              onChanged: (value) {
                setState(() => _respectError = null);
                widget.meetingReview.respect = value;
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              horizontalTitleGap: 0,
              value: widget.meetingReview.anonymous,
              onChanged:
                  (val) => setState(
                    () => widget.meetingReview.anonymous = val ?? false,
                  ),
              title: Text(loc.meetingReviewAnonymous),
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
