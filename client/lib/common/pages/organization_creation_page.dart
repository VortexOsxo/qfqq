import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/services/organization_service.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/generated/l10n.dart';

class OrganizationCreationPage extends ConsumerStatefulWidget {
  const OrganizationCreationPage({super.key});

  @override
  ConsumerState<OrganizationCreationPage> createState() =>
      _OrganizationCreationPageState();
}

class _OrganizationCreationPageState
    extends ConsumerState<OrganizationCreationPage> {
  final _formKey = GlobalKey<FormState>();
  String organizationName = '';
  String? error;
  bool isLoading = false;

  void _submit() async {
    setState(() {
      error = null;
      isLoading = true;
    });

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final orgService = ref.read(organizationServiceProvider);
      final orgSlug = await orgService.createOrganization(organizationName);

      if (!mounted) return;

      if (orgSlug != null) {
        context.go('/login');
      } else {
        setState(() {
          error = S.of(context).errorUnknown;
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: loc.organizationCreationPageLabelName,
            ),
            validator: (value) =>
                value == null || value.isEmpty ? loc.errorRequiredField : null,
            onSaved: (val) => organizationName = val ?? '',
          ),
          const SizedBox(height: 24),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (isLoading)
            const CircularProgressIndicator()
          else
            ElevatedButton(
              style: squareButtonStyle(context),
              onPressed: _submit,
              child: Text(loc.organizationCreationPageButton),
            ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go('/login'),
            child: Text(loc.commonBack),
          ),
        ],
      ),
    );
  }
}
