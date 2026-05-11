import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_state.dart';

/// Manages app-level settings (theme).
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState()) {
    _load();
  }

  /// SharedPreferences key. Value: `true` = dark, `false`/missing = light.
  static const _themeKey = 'theme_dark';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    emit(SettingsState(themeMode: isDark ? ThemeMode.dark : ThemeMode.light));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    // Only light and dark are supported.
    final next = mode == ThemeMode.dark ? ThemeMode.dark : ThemeMode.light;
    if (state.themeMode == next) return;
    emit(state.copyWith(themeMode: next));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, next == ThemeMode.dark);
  }

  /// Flips between light and dark.
  Future<void> toggleTheme() async {
    await setThemeMode(
      state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  /// Wipes all persisted settings and resets to defaults. Called on logout.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeKey);
    emit(const SettingsState());
  }
}
