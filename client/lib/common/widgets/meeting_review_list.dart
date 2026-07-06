import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/meeting_review.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/common/utils/platform.dart';
import 'package:qfqq/generated/l10n.dart';

final meetingReviewsProvider = FutureProvider.family<List<MeetingReview>, int>((
  ref,
  meetingId,
) async {
  final service = ref.read(meetingAgendaServiceProvider);
  return await service.getReviews(meetingId);
});

class MeetingReviewList extends ConsumerWidget {
  final int meetingId;

  const MeetingReviewList({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);
    final reviewsAsync = ref.watch(meetingReviewsProvider(meetingId));

    return reviewsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (reviews) {
        if (reviews.isEmpty) {
          return Center(child: Text(loc.commonNoReviews));
        }

        return ListView.builder(
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];

            final user =
                review.anonymous
                    ? null
                    : ref.read(userByIdProvider(review.userId));

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? loc.meetingReviewAnonymousUser,
                      style: TextStyle(fontSize: 18),
                    ),
                    _grade(context, review),
                    if (review.comments.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        review.comments,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget scoreColumn( BuildContext context, String fullLabel, String shortLabel, int value) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value >= 0 ? value.toString() : '-',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Tooltip(
            message: fullLabel,
            child: Text(
              shortLabel,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget scoreLine(BuildContext context, String fullLabel, String shortLabel, int value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value >= 0 ? value.toString() : '-',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(width: 8),
        Tooltip(
          message: fullLabel,
          child: Text(
            shortLabel,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _grade(BuildContext context, MeetingReview review) {
    final loc = S.of(context);
    if (platformType == PlatformType.desktop) {
      return Row(
        children: [
          scoreColumn(context, loc.meetingReviewObjective, loc.meetingReviewObjectiveShort, review.objective),
          scoreColumn(context, loc.meetingReviewSmoothRunning, loc.meetingReviewSmoothRunningShort, review.smoothRunning),
          scoreColumn(context, loc.meetingReviewPreparation, loc.meetingReviewPreparationShort, review.preparation),
          scoreColumn(context, loc.meetingReviewLength, loc.meetingReviewLengthShort, review.length),
          scoreColumn(context, loc.meetingReviewRespect, loc.meetingReviewRespectShort, review.respect),
        ],
      );
    }

    return Column(
      children: [
        scoreLine(context, loc.meetingReviewObjective, loc.meetingReviewObjectiveShort, review.objective),
        scoreLine(context, loc.meetingReviewSmoothRunning, loc.meetingReviewSmoothRunningShort, review.smoothRunning),
        scoreLine(context, loc.meetingReviewPreparation, loc.meetingReviewPreparationShort, review.preparation),
        scoreLine(context, loc.meetingReviewLength, loc.meetingReviewLengthShort, review.length),
        scoreLine(context, loc.meetingReviewRespect, loc.meetingReviewRespectShort, review.respect),
    ],);
  }
}
