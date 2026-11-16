import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/providers/meeting_agendas_provider.dart';
import 'package:qfqq/common/providers/projects_provider.dart';
import 'package:qfqq/common/utils/is_id_valid.dart';
import 'package:qfqq/common/utils/platform.dart';

class NavigationTextLink extends StatelessWidget {
  final String text;
  final VoidCallback navigate;

  const NavigationTextLink({
    super.key,
    required this.text,
    required this.navigate,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = Colors.blue.shade700;

    return TextButton(
      onPressed: navigate,
      style: TextButton.styleFrom(
        foregroundColor: accentColor,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: accentColor,
          fontSize: isMobile ? 12 : 14
        ),
      ),
    );
  }
}

class ProjectNavigationTextLink extends ConsumerWidget {
  final int? projectId;

  const ProjectNavigationTextLink({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isIdValid(projectId)) {
      return SizedBox.shrink();
    }

    Future<Object?> navigate() => context.push('/projects/$projectId');
    final name = ref.watch(projectProviderById(projectId!).select((p) => p?.title));
    if (name == null) {
      return SizedBox.shrink();
    }

    return NavigationTextLink(text: '$name/', navigate: navigate);
  }
}

class ProjectAndMeetingNavigationTextLink extends ConsumerWidget {
  final int? projectId;
  final int? meetingId;

  const ProjectAndMeetingNavigationTextLink({super.key, required this.projectId, required this.meetingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isIdValid(projectId) && !isIdValid(meetingId)) {
      return SizedBox.shrink();
    }

    Future<Object?> mNavigate() => context.push('/agendas/$meetingId');
    Future<Object?> pNavigate() => context.push('/projects/$projectId');

    final mName = ref.watch(meetingAgendaByIdProvider(meetingId!).select((m) => m?.title));
    final pName = ref.watch(projectProviderById(projectId!).select((p) => p?.title));

    return Row(children: [
      if (pName != null) ...[
        NavigationTextLink(text: pName, navigate: pNavigate),
        Text('/', style: TextStyle(color: Colors.blue.shade700)),
      ],
      if (mName != null)
        NavigationTextLink(text: mName, navigate: mNavigate),
      ],
    );
  }
}

class NavigationTextButton extends ConsumerWidget {
  final String title;
  final void Function() navigate;

  const NavigationTextButton({super.key, required this.title, required this.navigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: navigate,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: TextStyle(color: theme.primaryColor)),
          const SizedBox(width: 4),
          Transform.translate(
            offset: const Offset(0, 1),
            child: Icon(
              Icons.arrow_forward,
              size: 16,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}