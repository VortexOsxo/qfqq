import 'package:flutter/foundation.dart';

enum PlatformType { mobile, desktop, unknown }

PlatformType _checkPlatform() {
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

final PlatformType platformType = _checkPlatform();

final isMobile = platformType == PlatformType.mobile;
final isDesktop = platformType == PlatformType.desktop;
final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
