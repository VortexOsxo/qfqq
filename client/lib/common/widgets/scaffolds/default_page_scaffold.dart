import 'package:flutter/material.dart';
import 'package:qfqq/common/widgets/common_app_bar.dart';
import 'package:qfqq/common/widgets/sidebar_widget.dart';

Scaffold defaultPageScaffold(BuildContext context, Widget child, {String? title}) {
  String pageTitle = title ?? "QFQQ";

  return Scaffold(
    appBar: CommonAppBar(title: pageTitle),
    body: Row(
      children: [
        SidebarWidget(),
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.primary,
            padding: EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: child,
            ),
          ),
        ),
      ],
    ),
  );
}
