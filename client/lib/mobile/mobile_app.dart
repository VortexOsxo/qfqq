import 'package:flutter/material.dart';
import 'package:qfqq/mobile/mobile_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:qfqq/generated/l10n.dart';

class MobileApp extends StatelessWidget {
  const MobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: mobileRouter,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      localeListResolutionCallback: (locales, supportedLocales) {
        if (locales != null) {
          for (var locale in locales) {
            if (locale.languageCode == 'en') {
              return const Locale('en');
            }
            if (locale.languageCode == 'fr') {
              return const Locale('fr');
            }
          }
        }
        return const Locale('fr');
      },
    );
  }
}
