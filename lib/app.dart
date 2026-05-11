import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'features/auth/auth_wrapper.dart';
import 'l10n/generated/app_localizations.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:device_preview/device_preview.dart';

import 'config/app_config.dart';
import 'features/alarms/cubit/alarm_cubit.dart';
import 'features/alarms/screens/alarm_stop_screen.dart';
import 'features/chat/cubit/chat_list_cubit.dart';
import 'features/onboarding/cubit/onboarding_cubit.dart';
import 'features/settings/cubit/settings_cubit.dart';
import 'features/settings/cubit/settings_state.dart';
import 'features/subscription/cubit/subscription_cubit.dart';
import 'shared/theme/app_theme.dart';

class SkeletonApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const SkeletonApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsCubit()),
        BlocProvider(create: (_) => AlarmCubit()),
        BlocProvider(create: (_) => SubscriptionCubit()),
        BlocProvider(create: (_) => OnboardingCubit()),
        BlocProvider(create: (_) => ChatListCubit()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) => ScreenUtilInit(
          designSize: const Size(414, 896),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppConfig.appName,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.themeMode,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: DevicePreview.locale(context),
            navigatorKey: navigatorKey,
            navigatorObservers: [PosthogObserver()],
            builder: (context, child) => DevicePreview.appBuilder(
              context,
              GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: child,
              ),
            ),
            initialRoute: '/',
            routes: {
              '/': (_) => AuthWrapper(navigatorKey: navigatorKey),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/alarm-dismiss') {
                final args = settings.arguments as Map<String, String>;
                final alarmId = args['alarmId']!;
                final nativeAlarmId = args['nativeAlarmId'] ?? alarmId;
                final label = args['label'] ?? 'Alarm';

                return MaterialPageRoute(
                  builder: (_) => AlarmStopScreen(
                    alarmId: alarmId,
                    nativeAlarmId: nativeAlarmId,
                    alarmLabel: label,
                  ),
                );
              }
              return null;
            },
          ),
        ),
      ),
    );
  }
}
