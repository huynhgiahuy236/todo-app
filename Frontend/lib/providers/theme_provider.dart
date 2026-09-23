import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const _storage = FlutterSecureStorage();
  static const _keyTheme = 'app_theme_mode';

  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final saved = await _storage.read(key: _keyTheme);
    if (saved == 'light') {
      state = ThemeMode.light;
    } else if (saved == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    if (mode == ThemeMode.light) {
      await _storage.write(key: _keyTheme, value: 'light');
    } else if (mode == ThemeMode.dark) {
      await _storage.write(key: _keyTheme, value: 'dark');
    } else {
      await _storage.write(key: _keyTheme, value: 'system');
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
