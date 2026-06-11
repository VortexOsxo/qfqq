import 'package:flutter/material.dart';
import 'package:qfqq/common/widgets/common_app_bar.dart';
import 'package:qfqq/mobile/widgets/bottom_bar_widget.dart';

Scaffold mobilePageScaffold(BuildContext context, Widget child, {String? title}) {
  return Scaffold(
    appBar: CommonAppBar(title: title ?? 'QFQQ'),
    body: child,
    bottomNavigationBar: BottomBarWidget(),
  );
}
