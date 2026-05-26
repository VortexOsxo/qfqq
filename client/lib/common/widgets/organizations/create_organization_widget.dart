import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/services/organization_service.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/generated/l10n.dart';

class CreateOrganizationWidget extends ConsumerStatefulWidget {
  const CreateOrganizationWidget({super.key});

  @override
  ConsumerState<CreateOrganizationWidget> createState() => _CreateOrganizationWidgetState();
}

class _CreateOrganizationWidgetState extends ConsumerState<CreateOrganizationWidget> {
  final TextEditingController _orgNameController = TextEditingController();
  String? _createError;
  bool _isLoading = false;

  @override
  void dispose() {
    _orgNameController.dispose();
    super.dispose();
  }

  void _createOrganization() async {
    final String name = _orgNameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _createError = S.of(context).errorRequiredField;
      });
      return;
    }

    setState(() {
      _createError = null;
      _isLoading = true;
    });

    await ref.read(organizationServiceProvider).createOrganization(name);
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });
    context.go('/');
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
                controller: _orgNameController,
                decoration: InputDecoration(
                  labelText: loc.organizationCreationPageLabelName,
                  errorText: _createError,
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                enabled: !_isLoading,
                onFieldSubmitted: (_) => _createOrganization(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: squareButtonStyle(context),
                onPressed: _isLoading ? null : _createOrganization,
                child: Text(loc.organizationCreationPageButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
