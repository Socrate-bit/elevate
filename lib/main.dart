import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'app.dart';
import 'config/app_config.dart';
import 'firebase_options.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Pre-warms the liquid glass shaders used by the home GlassBottomBar.
  await LiquidGlassWidgets.initialize();

  // FirebaseFunctions.instance.useFunctionsEmulator('192.168.1.69', 5001);

  // Match paywall locale to the device locale (e.g. "en_US", "fr_FR").
  final options = SuperwallOptions()..localeIdentifier = Platform.localeName;
  Superwall.configure(AppConfig.superwallPublicKey, options: options);
  runApp(
    LiquidGlassWidgets.wrap(
      adaptiveQuality: true,
      // DevicePreview(
      //   enabled: !kReleaseMode,
      //   data: DevicePreviewData(
      //     deviceIdentifier: Devices.ios.iPhoneSE.identifier.toString(),
      //     isFrameVisible: true,
      //   ),
      //   builder: (context) =>
      child: SkeletonApp(navigatorKey: _navigatorKey),
      // ),
    ),
  );
}
