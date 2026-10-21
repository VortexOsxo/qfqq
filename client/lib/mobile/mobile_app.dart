import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qfqq/common/providers/router_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:qfqq/generated/l10n.dart';
import 'package:qfqq/common/providers/locale_provider.dart';
import 'package:qfqq/common/theme/theme.dart';

class MobileApp extends ConsumerWidget {
  const MobileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: ref.read(routerProvider),
      locale: ref.watch(localeProvider),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      theme: lightTheme,
    );
  }
}
