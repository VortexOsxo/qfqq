import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SidebarNotifier extends Notifier<bool> {
  static const _sidebarKey = 'sidebar_visible';

  @override
  bool build() {
    _loadState();
    return true;
  }

  void toggle() {
    setSidebarVisible(!state);
  }

  Future<void> setSidebarVisible(bool visible) async {
    if (state == visible) return;
    state = visible;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sidebarKey, visible);
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_sidebarKey);
    if (saved != null && saved != state) {
      state = saved;
    }
  }
}

final sidebarProvider = NotifierProvider(() => SidebarNotifier());
