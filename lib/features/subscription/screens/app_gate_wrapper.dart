import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';

import '../cubit/subscription_cubit.dart';
import '../cubit/subscription_state.dart';
import '../../navigation/appy_shell.dart';

/// Subscription gate. Renders [AppyShell] once the user has access — wrapped in
/// a tap-catching paywall overlay when access is missing.
class AppGateWrapper extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const AppGateWrapper({super.key, required this.navigatorKey});

  @override
  State<AppGateWrapper> createState() => _AppGateWrapperState();
}

class _AppGateWrapperState extends State<AppGateWrapper> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, sub) {
        final subReady =
            sub.isLoaded && sub.status != SubscriptionGateStatus.unknown;
        if (!subReady) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (sub.hasAccess) {
          return const AppyShell();
        }

        // In debug builds, let the app be used without a sub so the UI can be
        // developed/tested. Production still gates with the tap-catching paywall.
        if (kDebugMode) {
          return const AppyShell();
        }
        Superwall.shared.registerPlacement('app_start');
        return Stack(
          children: [
            const AppyShell(),
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Superwall.shared.registerPlacement('app_start'),
              ),
            ),
          ],
        );
      },
    );
  }
}
