import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/onboarding_cubit.dart';
import '../widgets/language_selector.dart';
import '../widgets/onboarding_auth_step.dart';
import '../widgets/welcome_step_v2.dart';

/// First screen of onboarding. Lives before the funnel: new users tap
/// "Get started" ([onStart]) to enter it, while returning users open the
/// dedicated sign-in screen from the "Sign in" link. Header carries a brand
/// badge (left) and the language selector (right).
class OnboardingStartScreen extends StatelessWidget {
  final VoidCallback onStart;

  const OnboardingStartScreen({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top bar: brand badge left, language selector right.
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 8.h, 16.w, 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      l10n.onboardingAppyStartBadge,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: c.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: LanguageFlagButton(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: WelcomeStepV2(
                onGetStarted: onStart,
                onSignIn: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const _StartSignInScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standalone sign-in screen reachable from the start screen's "Sign in" link.
/// After a successful sign-in it routes returning users straight into the app
/// (or back into the funnel if they never finished onboarding).
class _StartSignInScreen extends StatelessWidget {
  const _StartSignInScreen();

  Future<void> _handleAuthenticated(BuildContext context) async {
    final cubit = context.read<OnboardingCubit>();
    final navigator = Navigator.of(context);
    final completed = await cubit.hasCompletedOnboarding();
    if (completed) {
      // Returning user — skip the funnel and drop into the app.
      cubit.finishOnboarding();
    } else {
      // Signed in but never finished — resume the funnel.
      cubit.startOnboarding();
    }
    // Pop this route so AuthWrapper's reactively-swapped subtree shows.
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: withHaptic(() => Navigator.of(context).pop()),
                    child: Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: c.card,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.chevron_left_rounded,
                          size: 26.sp, color: c.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: OnboardingAuthStep(
                mode: OnboardingAuthMode.signIn,
                title: l10n.onboardingAppySignInTitle,
                subtitle: l10n.onboardingAppySignInSubtitle,
                onAuthenticated: () => _handleAuthenticated(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
