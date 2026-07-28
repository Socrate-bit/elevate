import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../auth/auth_service.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import 'email_password_modal.dart';

enum OnboardingAuthMode { signIn, signUp }

/// Reusable auth page for the Appy onboarding funnel. Used twice: an early
/// sign-in for returning users, and a sign-up at the end. Reuses [AuthService]
/// and [showEmailPasswordModal]; the flow screen decides what happens next via
/// [onAuthenticated] and the optional [onSecondary] action.
class OnboardingAuthStep extends StatefulWidget {
  final OnboardingAuthMode mode;
  final String title;
  final String subtitle;

  /// Called after any successful sign-in / sign-up.
  final VoidCallback onAuthenticated;

  /// Optional tertiary action (e.g. "I'm new here" on the sign-in page).
  final VoidCallback? onSecondary;
  final String? secondaryLabel;

  const OnboardingAuthStep({
    super.key,
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.onAuthenticated,
    this.onSecondary,
    this.secondaryLabel,
  });

  @override
  State<OnboardingAuthStep> createState() => _OnboardingAuthStepState();
}

class _OnboardingAuthStepState extends State<OnboardingAuthStep> {
  bool _loading = false;

  bool get _isSignUp => widget.mode == OnboardingAuthMode.signUp;

  Future<void> _showAuthDialog(String message) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.generalOk),
          ),
        ],
      ),
    );
  }

  Future<void> _runAuth(Future<void> Function() action, String failureMsg) async {
    setState(() => _loading = true);
    try {
      await action();
      if (mounted) widget.onAuthenticated();
    } catch (e) {
      debugPrint('[OnboardingAuthStep] auth failed: $e');
      if (mounted) await _showAuthDialog(failureMsg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleEmailAuth() async {
    final ok = await showEmailPasswordModal(
      context,
      allowSignUp: true,
      initialSignUpMode: _isSignUp,
    );
    if (ok == true && mounted) widget.onAuthenticated();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: c.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            widget.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp, color: c.textSecondary),
          ),
          SizedBox(height: 32.h),
          // Continue with Apple
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton.icon(
              onPressed: _loading
                  ? null
                  : withHaptic(() => _runAuth(
                        () => AuthService.signInWithApple(),
                        l10n.onboardingAppleFailed,
                      )),
              icon: Icon(Icons.apple, size: 24.sp, color: c.card),
              label: Text(
                l10n.onboardingSignInApple,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: c.card,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: c.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // Continue with Google
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: OutlinedButton(
              onPressed: _loading
                  ? null
                  : withHaptic(() => _runAuth(
                        () => AuthService.signInWithGoogle(),
                        l10n.onboardingGoogleFailed,
                      )),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: c.separator, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.r),
                ),
              ),
              child: Text(
                l10n.onboardingSignInGoogle,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: c.textPrimary,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: _loading ? null : withHaptic(_handleEmailAuth),
            child: Text(
              l10n.onboardingSignInEmail,
              style: TextStyle(
                fontSize: 14.sp,
                color: c.textSecondary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          if (_loading)
            const CircularProgressIndicator()
          else if (widget.onSecondary != null && widget.secondaryLabel != null)
            GestureDetector(
              onTap: withHaptic(widget.onSecondary!),
              child: Text(
                widget.secondaryLabel!,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: c.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
