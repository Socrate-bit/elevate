import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_preview/device_preview.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // FirebaseFunctions.instance.useFunctionsEmulator('192.168.1.69', 5001);

  // Match paywall locale to the device locale (e.g. "en_US", "fr_FR").
  final options = SuperwallOptions()..localeIdentifier = Platform.localeName;
  Superwall.configure('pk_H0nPpphGj3awY7K1T2ngX', options: options);
  runApp(
    // DevicePreview(
    //   enabled: !kReleaseMode,
    //   data: DevicePreviewData(
    //     deviceIdentifier: Devices.ios.iPhoneSE.identifier.toString(),
    //     isFrameVisible: true,
    //   ),
    //   builder: (context) =>
    LevioApp(navigatorKey: _navigatorKey),
    // ),
  );
}
