import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'app.dart';
import 'config/app_config.dart';
import 'firebase_options.dart';
import 'features/notifications/notification_service.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Sets up the timezone DB + local notifications plugin for reminders.
  await NotificationService.init();
  // Pre-warms the liquid glass shaders used by the home GlassBottomBar.
  await LiquidGlassWidgets.initialize();

  // Match paywall locale to the device locale (e.g. "en_US", "fr_FR").
  final options = SuperwallOptions()..localeIdentifier = Platform.localeName;
  Superwall.configure(AppConfig.superwallPublicKey, options: options);

  runApp(
    LiquidGlassWidgets.wrap(
      adaptiveQuality: true,
      child: AppyApp(navigatorKey: _navigatorKey),
    ),
  );
}
