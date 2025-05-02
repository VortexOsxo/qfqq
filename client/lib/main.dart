import 'package:flutter/material.dart';
import 'package:qfqq/common/utils/platform.dart';
import 'package:qfqq/desktop/desktop_app.dart';
import 'package:qfqq/mobile/mobile_app.dart';

void main() {
  final platform = checkPlatform();
  if (platform == PlatformType.desktop) {
    runApp(const DesktopApp());
  } else if (platform == PlatformType.mobile) {
    runApp(const MobileApp());
  }
}
