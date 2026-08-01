import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// All app-level preferences (theme + locale + behaviour toggles).
class SettingsState extends Equatable {
  final ThemeMode themeMode;

  /// User-selected language override. Null follows the device locale.
  final Locale? locale;

  const SettingsState({
    this.themeMode = ThemeMode.light,
    this.locale,
  });

  SettingsState copyWith({ThemeMode? themeMode, Locale? locale}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => [themeMode, locale];
}
