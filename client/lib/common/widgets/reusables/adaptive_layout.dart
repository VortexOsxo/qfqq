import 'package:flutter/material.dart';
import 'package:qfqq/common/utils/platform.dart';

class AdaptiveLayout extends StatelessWidget {
  final WidgetBuilder mobile;
  final WidgetBuilder desktop;

  const AdaptiveLayout({super.key, required this.mobile, required this.desktop});

  @override
  Widget build(BuildContext context) {
    return checkPlatform() == PlatformType.mobile
        ? mobile(context)
        : desktop(context);
  }
}
