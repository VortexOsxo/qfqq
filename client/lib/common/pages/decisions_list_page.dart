import 'package:flutter/material.dart';
import 'package:qfqq/common/templates/page_template.dart';
import 'package:qfqq/common/widgets/decisions/decisions_list_widget.dart';
import 'package:qfqq/generated/l10n.dart';


class DecisionsListPage extends StatelessWidget {
  const DecisionsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    String title = S.of(context).decisionsListPageTitle;
    Widget content = DecisionsListWidget(refetch:true);
    return buildPageTemplate(context, content, title);
  }
}
