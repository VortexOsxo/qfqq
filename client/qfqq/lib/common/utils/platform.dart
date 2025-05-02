import 'package:flutter/foundation.dart';

enum PlatformType { mobile, desktop, unknown }

PlatformType checkPlatform() {
  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    return PlatformType.mobile;
  } else if (defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux) {
    return PlatformType.desktop;
  }
  return PlatformType.unknown;
}
