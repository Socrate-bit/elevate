import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';

/// Welcome landing for the onboarding start screen: top-anchored headline,
/// the Appy mascot, a prominent black start button, a social-proof line, and a
/// "Sign in" link for returning users (email sign-in lives on its own screen).
class WelcomeStepV2 extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  const WelcomeStepV2({
    super.key,
    required this.onGetStarted,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('⭐⭐⭐⭐⭐', style: TextStyle(fontSize: 28.sp)),
            SizedBox(height: 24.h),
            // Headline anchored to the top.
            Text(
              l10n.onboardingAppyStartTitle,
              style: TextStyle(
                fontSize: 34.sp,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
                height: 1.12,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.onboardingAppyStartSubtitle,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: c.textSecondary,
                height: 1.35,
              ),
            ),
            const Spacer(),
            // Mascot.
            Center(
              child: Image.asset(
                'assets/chat/appy_avatar_nobg.png',
                height: 200.h,
                fit: BoxFit.contain,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 60.h,
              child: ElevatedButton(
                onPressed: withHaptic(onGetStarted),
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.textPrimary,
                  foregroundColor: c.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.onboardingGetStarted,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: c.card,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.arrow_forward, size: 20.sp, color: c.card),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Center(
              child: Text(
                l10n.onboardingAppyStartJoin,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: c.textSecondary,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Center(
              child: GestureDetector(
                onTap: withHaptic(onSignIn),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 15.sp, color: c.textSecondary),
                    children: [
                      TextSpan(text: l10n.onboardingAppyAlreadyAccount),
                      TextSpan(
                        text: l10n.onboardingSignIn,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: c.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
