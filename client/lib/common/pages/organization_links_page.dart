import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/services/organization_service.dart';
import 'package:qfqq/common/theme/styles.dart';
import 'package:qfqq/common/widgets/common_app_bar.dart';
import 'package:qfqq/generated/l10n.dart';

class OrganizationLinksPage extends ConsumerStatefulWidget {
  const OrganizationLinksPage({super.key});

  @override
  ConsumerState<OrganizationLinksPage> createState() =>
      _OrganizationLinksPageState();
}

class _OrganizationLinksPageState extends ConsumerState<OrganizationLinksPage> {
  final TextEditingController _orgIdController = TextEditingController();
  String? _joinError;
  bool _isLoading = false;

  @override
  void dispose() {
    _orgIdController.dispose();
    super.dispose();
  }

  void _joinOrganization() async {
    final String input = _orgIdController.text.trim();
    final int? orgId = int.tryParse(input);
    if (orgId == null) {
      setState(() {
        _joinError = S.current.errorRequiredField;
        _isLoading = false;
      });
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
    final theme = Theme.of(context);
    final loc = S.of(context);

    return Scaffold(
      appBar: CommonAppBar(
        title: loc.organizationLinksPageTitle,
        showHomeButton: false,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: theme.colorScheme.primary,
              tabs: [
                Tab(
                  icon: const Icon(Icons.group_add_outlined),
                  text: loc.organizationLinksTabJoin,
                ),
                Tab(
                  icon: const Icon(Icons.add_business_outlined),
                  text: loc.organizationLinksTabCreate,
                ),
              ],
            ),
            Expanded(child: TabBarView(children: [_joinTab(context), _buildTab(context)])),
          ],
        ),
      ),
    );
  }

  _buildTab(BuildContext context) {
    final loc = S.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          loc.organizationLinksCreateDummy,
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  _joinTab(BuildContext context) {
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
            ],
          ),
        ),
      ),
    );
  }
}
