import 'package:flutter/material.dart';
import 'package:qfqq/common/widgets/common_app_bar.dart';

Scaffold authPageScaffold(
  BuildContext context,
  Widget child, {
  String? title,
}) {
  String pageTitle = title ?? "QFQQ";

  return Scaffold(
    appBar: CommonAppBar(title: pageTitle, showHomeButton: false),
    body: Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: child
        ),
      ),
    ),
  );
}
