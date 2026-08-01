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

  /// SharedPreferences key. Value: language code (e.g. `en`, `fr`); missing
  /// follows the device locale.
  static const _localeKey = 'locale_code';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    final code = prefs.getString(_localeKey);
    emit(SettingsState(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      locale: code != null ? Locale(code) : null,
    ));
  }

  /// Overrides the app language and persists it. Re-localizes the whole app
  /// reactively via [SettingsState.locale].
  Future<void> setLocale(Locale locale) async {
    if (state.locale?.languageCode == locale.languageCode) return;
    emit(state.copyWith(locale: locale));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    debugPrint('[SettingsCubit] locale set to ${locale.languageCode}');
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

  /// Wipes user-scoped settings and resets to defaults. Called on logout.
  /// The language choice is a device-level preference and is intentionally
  /// preserved (it also drives the signed-out onboarding language selector).
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeKey);
    emit(SettingsState(locale: state.locale));
  }
}
