import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/widgets/details_attribute_widget.dart';
import 'package:qfqq/generated/l10n.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    if (authState.username == null || authState.email == null) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          _buildTopCard(context, ref),

          const SizedBox(height: 16),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: SizedBox(
                    width: 150,
                    child: _buildAccountInfo(context, ref, authState),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCard(BuildContext context, WidgetRef ref) {
    final loc = S.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(8),
      child: Text(
        loc.commonProfile,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: theme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildAccountInfo(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
  ) {
    final loc = S.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailsAttributeWidget(label: loc.attributeUsername, value: authState.username!),
          DetailsAttributeWidget(label: loc.attributeEmail, value: authState.email!),
        ],
      ),
    );
  }
}
