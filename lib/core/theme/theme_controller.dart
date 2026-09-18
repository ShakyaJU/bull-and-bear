import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModePrefKey = 'theme_mode';

/// A Notifier is Riverpod's way of holding a piece of state that CAN
/// change over time (unlike a plain Provider, which builds something once).
/// This one holds the current ThemeMode and knows how to save/load it so
/// the choice survives an app restart.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Kick off loading the saved preference; until it resolves, default
    // to following the phone's system setting.
    _loadSavedThemeMode();
    return ThemeMode.system;
  }

  Future<void> _loadSavedThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeModePrefKey);
    state = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModePrefKey, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
