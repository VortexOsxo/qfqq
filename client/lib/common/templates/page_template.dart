import 'package:flutter/material.dart';
import 'package:qfqq/common/widgets/common_app_bar.dart';
import 'package:qfqq/common/widgets/sidebar_widget.dart';

Widget buildPageTemplate(BuildContext context, Widget content, String? title) {
  return Scaffold(
    appBar: CommonAppBar(title: title ?? 'Welcome'),
    body: Row(children: [SidebarWidget(), _buildInside(context, content)]),
  );
}

Widget _buildInside(BuildContext context, Widget content) {
  
  return Expanded(
    child: Container(
      color: Theme.of(context).colorScheme.primary,
      padding: EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: content,
      ),
    ),
  );
}
