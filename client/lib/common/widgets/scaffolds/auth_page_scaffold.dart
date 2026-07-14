import 'package:flutter/material.dart';
import 'package:qfqq/common/utils/platform.dart';
import 'package:qfqq/common/widgets/common_app_bar.dart';

Scaffold authPageScaffold(
  BuildContext context,
  Widget child, {
  String? title,
}) {
  String pageTitle = title ?? "QFQQ";

  final screenWidth = MediaQuery.of(context).size.width;
  final isMobile = platformType == PlatformType.mobile;

  return Scaffold(
    appBar: CommonAppBar(title: pageTitle, showHomeButton: false),
    body: Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isMobile ? 500 : screenWidth,
          ),
          child: child,
        ),
      ),
    ),
  );
}
