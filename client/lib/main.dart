import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/services/web_socket_service.dart';
import 'package:qfqq/common/utils/platform.dart';
import 'package:qfqq/desktop/desktop_app.dart';
import 'package:qfqq/firebase_options.dart';
import 'package:qfqq/mobile/mobile_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  WebSocketService.connect();

  if (platformType == PlatformType.desktop) {
    runApp(ProviderScope(child: const DesktopApp()));
  } else if (platformType == PlatformType.mobile) {
    runApp(ProviderScope(child: const MobileApp()));
  }
}
