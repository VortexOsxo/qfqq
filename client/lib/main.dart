import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/router_provider.dart';
import 'package:qfqq/common/services/auth_service.dart';
import 'package:qfqq/common/services/web_socket_service.dart';
import 'package:qfqq/common/utils/platform.dart';
import 'package:qfqq/desktop/desktop_app.dart';
import 'package:qfqq/firebase_options.dart';
import 'package:qfqq/mobile/mobile_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  WebSocketService.connect();

  final container = ProviderContainer();

  try {
    final restored = await container.read(authStateProvider.notifier).refresh();
    final auth = container.read(authStateProvider);
    if (restored && auth.hasOrg) {
      container.read(routerProvider).go('/');
    }
  } catch (_) {

  }


  runApp(
    UncontrolledProviderScope(
      container: container,
      child:
          platformType == PlatformType.desktop
              ? const DesktopApp()
              : const MobileApp(),
    ),
  );
}
