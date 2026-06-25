import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/services/organization_service.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/generated/l10n.dart';

class JoinOrganizationWidget extends ConsumerStatefulWidget {
  const JoinOrganizationWidget({super.key});

  @override
  ConsumerState<JoinOrganizationWidget> createState() => _JoinOrganizationWidgetState();
}

class _JoinOrganizationWidgetState extends ConsumerState<JoinOrganizationWidget> {
  final TextEditingController _orgIdController = TextEditingController();
  String? _joinError;
  bool _isLoading = false;

  @override
  void dispose() {
    _orgIdController.dispose();
    super.dispose();
  }

  void _joinOrganization() async {
    final loc = S.of(context);
    final String input = _orgIdController.text.trim();

    if (input.isEmpty) {
      setState(() => _joinError = loc.errorRequiredField);
      return;
    }

    final int? orgId = int.tryParse(input);
    if (orgId == null) {
      setState(() => _joinError = loc.organizationJoinInvalidOrg);
      return;
    }

    setState(() {
      _joinError = null;
      _isLoading = true;
    });

    final orgService = ref.read(organizationServiceProvider);
    final String? errorMsg = await orgService.joinOrganisation(orgId);

    if (!mounted) return;

    if (errorMsg != null) {
      setState(() {
        _joinError = errorMsg;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _orgIdController,
                decoration: InputDecoration(
                  labelText: loc.organizationLinksInputId,
                  errorText: _joinError,
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                enabled: !_isLoading,
                onFieldSubmitted: (_) => _joinOrganization(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: squareButtonStyle(context),
                onPressed: _isLoading ? null : _joinOrganization,
                child: Text(loc.organizationLinksButtonJoin),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(loc.commonBack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
