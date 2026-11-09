import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:qfqq/common/services/organization_service.dart';
import 'package:qfqq/common/widgets/reusables/return_login_widget.dart';
import 'package:qfqq/common/widgets/scaffolds/auth_page_scaffold.dart';
import 'package:qfqq/generated/l10n.dart';

class SubscribePage extends ConsumerStatefulWidget {
  final bool hasOrganizationAccess;

  const SubscribePage({super.key, required this.hasOrganizationAccess});

  @override
  ConsumerState<SubscribePage> createState() => _SubscribePageState();
}

class _SubscribePageState extends ConsumerState<SubscribePage> {
  bool _isSubmitting = false;
  bool _requestSent = false;
  String? _errorMessage;

  Future<void> _requestSubscription() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final sent =
          await ref.read(organizationServiceProvider).requestSubscription();
      if (!mounted) return;

      setState(() {
        _requestSent = sent;
        if (!sent) {
          _errorMessage = S.of(context).subscribePageRequestError;
        }
      });
    } on http.ClientException {
      if (!mounted) return;
      setState(() {
        _errorMessage = S.of(context).subscribePageRequestError;
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final theme = Theme.of(context);
    final hasOrganizationAccess = widget.hasOrganizationAccess;

    final content = Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!hasOrganizationAccess) ...[
            Text(
              loc.subscribePageTrialEnded,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
          ],
          if (_requestSent)
            Text(
              loc.subscribePageRequestSent,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            )
          else ...[
            Text(
              loc.subscribePageContactPrompt,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSubmitting ? null : _requestSubscription,
              child:
                  _isSubmitting
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Text(loc.subscribePageButton),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
          if (!hasOrganizationAccess) ...[
            const SizedBox(height: 24),
            const ReturnLoginWidget(),
          ],
        ],
      ),
    );

    if (!hasOrganizationAccess) {
      return authPageScaffold(context, content, title: loc.subscribePageTitle);
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SingleChildScrollView(child: content),
      ),
    );
  }
}
