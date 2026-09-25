import 'package:flutter/material.dart';
import 'package:qfqq/common/widgets/reusables/return_login_widget.dart';
import 'package:qfqq/generated/l10n.dart';

class JoinOrganizationWidget extends StatelessWidget {
  const JoinOrganizationWidget({super.key});

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
              Text(loc.organizationLinksNoInvitation),
              const SizedBox(height: 24),
              ReturnLoginWidget()
            ],
          ),
        ),
      ),
    );
  }
}
