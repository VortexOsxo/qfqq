import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/models/meeting_review.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/providers/users_provider.dart';
import 'package:qfqq/generated/l10n.dart';

final meetingReviewsProvider =
    FutureProvider.family<List<MeetingReview>, int>((ref, meetingId) async {
  final service = ref.read(meetingAgendaServiceProvider);
  return await service.getReviews(meetingId);
});

class MeetingReviewList extends ConsumerWidget {
  final int meetingId;

  const MeetingReviewList({
    super.key,
    required this.meetingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);
    final reviewsAsync = ref.watch(meetingReviewsProvider(meetingId));

    return reviewsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (reviews) {
        if (reviews.isEmpty) {
          return Center(child: Text(loc.commonNoReviews));
        }

        return ListView.builder(
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];

            final user = review.anonymous ? null : ref.read(userByIdProvider(review.userId));

            Widget scoreColumn(String fullLabel, String shortLabel, int value) => Expanded(
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

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.displayName ?? loc.meetingReviewAnonymousUser, style: TextStyle(fontSize: 18)),
                    Row(
                      children: [
                        scoreColumn(loc.meetingReviewObjective, loc.meetingReviewObjectiveShort, review.objective),
                        scoreColumn(loc.meetingReviewSmoothRunning, loc.meetingReviewSmoothRunningShort, review.smoothRunning),
                        scoreColumn(loc.meetingReviewPreparation, loc.meetingReviewPreparationShort, review.preparation),
                        scoreColumn(loc.meetingReviewLength, loc.meetingReviewLengthShort, review.length),
                        scoreColumn(loc.meetingReviewRespect, loc.meetingReviewRespectShort, review.respect),
                      ],
                    ),
                    if (review.comments.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(review.comments, style: Theme.of(context).textTheme.bodyMedium),
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
}