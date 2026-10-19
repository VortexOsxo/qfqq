import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/models/states/auth_state.dart';
import 'package:qfqq/common/widgets/profile/language_settings_card.dart';
import 'package:qfqq/common/widgets/profile/notification_settings_section.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/utils/platform.dart';
import 'package:qfqq/generated/l10n.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    if (!authState.isAuthenticated) {
      // TODO: Had an explaition message and allow to 'disconnect' and go to login page
      return const SizedBox.shrink();
    }

    return _build(context, ref, authState);
  }

  Widget _build(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
  ) {
    final loc = S.of(context);

    void logout() async {
      var authService = ref.read(authStateProvider.notifier);
      await authService.logout();
      if (context.mounted) {
        context.go('/login');
      }
    }

    final isMobile = platformType == PlatformType.mobile;

    return LayoutBuilder(
      builder:
          (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildProfileHeader(context, loc, authState),
                          const SizedBox(height: 32),
                          if (!isMobile)
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: NotificationSettingsSection(),
                                ),
                                SizedBox(width: 32),
                                Expanded(
                                  flex: 2,
                                  child: LanguageSettingsCard(),
                                ),
                              ],
                            )
                          else ...[
                            const NotificationSettingsSection(),
                            const SizedBox(height: 24),
                            const LanguageSettingsCard(),
                            const Spacer(),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: logout,
                              style: squareButtonStyle(context),
                              child: Text(loc.profilePageLogout),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    S loc,
    AuthState authState,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.commonProfile,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              authState.user?.displayName ?? '',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              authState.user?.email ?? '',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
