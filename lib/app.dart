import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'features/auth/auth_wrapper.dart';
import 'l10n/generated/app_localizations.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:device_preview/device_preview.dart';

import 'config/app_config.dart';
import 'features/mood/cubit/mood_cubit.dart';
import 'features/chat/cubit/chat_list_cubit.dart';
import 'features/home/cubit/streak_cubit.dart';
import 'features/memory/cubit/memory_cubit.dart';
import 'features/onboarding/cubit/onboarding_cubit.dart';
import 'features/routines/cubit/routine_cubit.dart';
import 'features/settings/cubit/settings_cubit.dart';
import 'features/settings/cubit/settings_state.dart';
import 'features/shop/cubit/shop_cubit.dart';
import 'features/subscription/cubit/subscription_cubit.dart';
import '../features/adventure/cubit/adventure_cubit.dart';
import 'features/navigation/app_nav_cubit.dart';
import 'shared/theme/app_theme.dart';

class AppyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const AppyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MoodCubit()),
        BlocProvider(create: (_) => SettingsCubit()),
        BlocProvider(create: (_) => RoutineCubit()),
        BlocProvider(create: (_) => StreakCubit()),
        BlocProvider(create: (_) => SubscriptionCubit()),
        BlocProvider(create: (_) => OnboardingCubit()),
        BlocProvider(create: (_) => ChatListCubit()),
        BlocProvider(create: (_) => MemoryCubit()),
        BlocProvider(create: (_) => AppNavCubit()),
        BlocProvider(create: (_) => AdventureCubit()),
        BlocProvider(create: (_) => ShopCubit()),
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
            locale: settings.locale ?? DevicePreview.locale(context),
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
          ),
        ),
      ),
    );
  }
}
