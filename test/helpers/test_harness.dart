import 'package:elevate/l10n/generated/app_localizations.dart';
import 'package:elevate/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Pumps [child] inside the minimal scaffolding needed to render chat widgets:
/// ScreenUtilInit + MaterialApp + l10n delegates + light theme.
Widget harness(Widget child, {ThemeMode themeMode = ThemeMode.light}) {
  return ScreenUtilInit(
    designSize: const Size(414, 896),
    minTextAdapt: true,
    splitScreenMode: true,
    // ignore: unnecessary_underscores
    builder: (_, __) => MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}
