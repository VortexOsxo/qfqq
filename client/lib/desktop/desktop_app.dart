import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/initializer_provider.dart';
import 'package:qfqq/desktop/desktop_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:qfqq/generated/l10n.dart';

class DesktopApp extends ConsumerWidget {
  const DesktopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initalize the service that must be initialized on app starts
    ref.read(initializationProvider);

    return MaterialApp.router(
      routerConfig: desktopRouter,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
    );
  }
}
