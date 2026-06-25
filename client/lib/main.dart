import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/utils/platform.dart';
import 'package:qfqq/desktop/desktop_app.dart';
import 'package:qfqq/mobile/mobile_app.dart';

void main() {
  if (platformType == PlatformType.desktop) {
    runApp(ProviderScope(child: const DesktopApp()));
  } else if (platformType == PlatformType.mobile) {
    runApp(ProviderScope(child: const MobileApp()));
  }
}
