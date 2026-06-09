import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qfqq/common/utils/platform.dart';
import 'package:qfqq/desktop/desktop_router.dart';
import 'package:qfqq/mobile/mobile_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  if (platformType == PlatformType.desktop) {
    return desktopRouter;
  } else if (platformType == PlatformType.mobile) {
    return mobileRouter;
  }
  throw Exception('Unsupported platform: $platformType');
});

