import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

class LocaleNotifier extends Notifier<Locale> {
  static const _localeKey = 'app_locale';

  @override
  Locale build() {
    _loadLocale();
    
    final platformLanguageCode = ui.PlatformDispatcher.instance.locale.languageCode;
    if (platformLanguageCode == 'en') {
      return const Locale('en');
    }
    return const Locale('fr'); 
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey);
    if (languageCode != null) {
      if (state.languageCode != languageCode) {
        state = Locale(languageCode);
      }
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (state == locale) return;
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(() {
  return LocaleNotifier();
});
