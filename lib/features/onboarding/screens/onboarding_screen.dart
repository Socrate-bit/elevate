import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/utils/haptic_utils.dart';

import '../../../shared/theme/app_theme.dart';
import '../../subscription/cubit/subscription_cubit.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widgets/info_step.dart';
import '../widgets/loading_step.dart';
import '../widgets/notification_step.dart';
import '../widgets/paywall_step.dart';
import '../widgets/rating_step.dart';
import '../widgets/referral_step.dart';
import '../widgets/sign_in_step.dart';
import '../widgets/signature_step.dart';
import '../widgets/survey_step.dart';
import '../widgets/trial_reminder_step.dart';
import '../widgets/welcome_step.dart';

/// Onboarding flow page indices (Welcome is page 0; the rest live in a PageView).
///
///  0: Welcome
///  1–3: Survey × 3 (placeholder questions)
///  4: Info (placeholder)
///  5: Notification permission (owns nav)
///  6: Rating (triggers in-app review on Continue)
///  7: Signature (owns nav)
///  8: Loading (auto-advances)
///  9: Sign-in (owns nav)
/// 10: Referral
/// 11: Paywall (owns nav)
/// 12: Trial reminder (FINAL — calls completeOnboarding + finishOnboarding)
const _totalPages = 13;

const _surveyQuestions = [
  ('survey_q1', 'Question 1?'),
  ('survey_q2', 'Question 2?'),
  ('survey_q3', 'Question 3?'),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goToPage(int page) async {
    final wasOnWelcome = _currentPage == 0;
    setState(() => _currentPage = page);
    if (page >= 1 && page < _totalPages) {
      if (wasOnWelcome) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _pageController.jumpToPage(0);
        });
      } else {
        await _pageController.animateToPage(
          page - 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _next() => _goToPage(_currentPage + 1);

  void _back() {
    if (_currentPage > 0) _goToPage(_currentPage - 1);
  }

  Future<void> _handleContinuePress(
    OnboardingState state,
    OnboardingCubit cubit,
  ) async {
    // Rating page: trigger in-app review.
    if (_currentPage == 6) {
      InAppReview.instance.requestReview();
    }
    // Referral page: validate any entered code before advancing.
    if (_currentPage == 10) {
      final code = state.referralCode.trim();
      FocusScope.of(context).unfocus();
      if (code.isNotEmpty &&
          state.referralStatus != ReferralStatus.valid) {
        await cubit.submitReferralCode();
        if (!mounted) return;
        if (cubit.state.referralStatus != ReferralStatus.valid) return;
      }
    }
    _next();
  }

  Future<void> _completeFlow() async {
    final cubit = context.read<OnboardingCubit>();
    final subscription = context.read<SubscriptionCubit>();
    await cubit.completeOnboarding(subscription);
    cubit.finishOnboarding();
  }

  Widget _buildPage(int index) {
    final l10n = AppLocalizations.of(context)!;
    return switch (index) {
      0 => SurveyStep(
          question: _surveyQuestions[0].$2,
          questionKey: _surveyQuestions[0].$1,
        ),
      1 => SurveyStep(
          question: _surveyQuestions[1].$2,
          questionKey: _surveyQuestions[1].$1,
        ),
      2 => SurveyStep(
          question: _surveyQuestions[2].$2,
          questionKey: _surveyQuestions[2].$1,
        ),
      3 => InfoStep(
          title: l10n.onboardingInfoTitle,
          body: l10n.onboardingInfoBody,
        ),
      4 => NotificationStep(onContinue: _next),
      5 => const RatingStep(),
      6 => SignatureStep(onContinue: _next),
      7 => LoadingStep(onComplete: _next),
      8 => SignInStep(onContinue: _next),
      9 => const ReferralStep(),
      10 => PaywallStep(onContinue: _next),
      11 => TrialReminderStep(onContinue: _completeFlow),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final cubit = context.read<OnboardingCubit>();

        if (_currentPage == 0) {
          return Scaffold(
            backgroundColor: c.background,
            body: SafeArea(
              child: WelcomeStep(
                onStart: () {
                  cubit.startOnboarding();
                  _next();
                },
              ),
            ),
          );
        }

        // Pages whose body owns its primary action button.
        const ownsNavPages = {5, 7, 8, 9, 11, 12};
        final ownsNav = ownsNavPages.contains(_currentPage);

        return Scaffold(
          backgroundColor: c.background,
          body: SafeArea(
            child: Column(
              children: [
                _ProgressBar(
                  current: _currentPage,
                  total: _totalPages,
                  onBack: _currentPage > 1 ? _back : null,
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _totalPages - 1,
                    itemBuilder: (_, i) => _buildPage(i),
                  ),
                ),
                if (!ownsNav)
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                    child: GestureDetector(
                      onTap: withHaptic(
                          () => _handleContinuePress(state, cubit)),
                      child: Container(
                        height: 54.h,
                        decoration: BoxDecoration(
                          color: c.primary,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          l10n.onboardingContinue,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final VoidCallback? onBack;

  const _ProgressBar({
    required this.current,
    required this.total,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final fraction = (current / (total - 1)).clamp(0.0, 1.0);
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: Row(
        children: [
          SizedBox(
            width: 36.w,
            child: onBack != null
                ? GestureDetector(
                    onTap: withHaptic(onBack),
                    child: Icon(Icons.arrow_back_ios_new,
                        size: 20.sp, color: c.textPrimary),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 4.h,
                backgroundColor: c.separator,
                valueColor: AlwaysStoppedAnimation<Color>(c.primary),
              ),
            ),
          ),
          SizedBox(width: 36.w),
        ],
      ),
    );
  }
}
