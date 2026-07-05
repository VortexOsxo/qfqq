import 'package:flutter/material.dart';
import 'package:qfqq/common/widgets/common_app_bar.dart';
import 'package:qfqq/common/widgets/organizations/create_organization_widget.dart';
import 'package:qfqq/common/widgets/organizations/join_organization_widget.dart';
import 'package:qfqq/generated/l10n.dart';

class OrganizationLinksPage extends StatelessWidget {
  const OrganizationLinksPage({super.key});

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
            const Expanded(
              child: TabBarView(
                children: [
                  JoinOrganizationWidget(),
                  CreateOrganizationWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
