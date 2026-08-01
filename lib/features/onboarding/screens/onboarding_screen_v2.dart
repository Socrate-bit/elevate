import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../../subscription/cubit/subscription_cubit.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widgets/education_step.dart';
import '../widgets/language_selector.dart';
import '../widgets/life_rating_step.dart';
import '../widgets/multi_select_step.dart';
import '../widgets/name_input_step.dart';
import '../widgets/onboarding_auth_step.dart';
import '../widgets/survey_step.dart';

/// Redesigned Appy onboarding funnel. Portrays the user's situation, educates,
/// personalizes Appy, then hands off to the app (the first conversation happens
/// in the chat). Reuses the shared [OnboardingCubit] for routing + persistence.
///
/// The returning-user sign-in lives on the [OnboardingStartScreen] before this
/// funnel; here we only run the personalization steps and the final sign-up.
///
/// Pages:
///  0  Privacy education (Main PCD)
///  1  Age
///  2  What do you identify with (multi)
///  3  How do you feel lately (multi)
///  4  Rate dimensions of your life (1–5)
///  5  Problem (education)
///  6  Solution (education)
///  7  Present Appy (education)
///  8  Name
///  9  How should Appy talk to you (tone)
/// 10  Sign up → complete                — owns nav
class OnboardingScreenV2 extends StatefulWidget {
  const OnboardingScreenV2({super.key});

  @override
  State<OnboardingScreenV2> createState() => _OnboardingScreenV2State();
}

class _OnboardingScreenV2State extends State<OnboardingScreenV2> {
  static const _totalPages = 11;

  final _pageController = PageController();
  int _currentPage = 0;
  bool _finalizing = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goToPage(int page) async {
    if (page < 0 || page >= _totalPages) return;
    setState(() => _currentPage = page);
    await _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _next() => _goToPage(_currentPage + 1);
  void _back() => _goToPage(_currentPage - 1);

  // Pages that render their own primary action (no shared Continue button).
  bool _ownsNav(int page) => page == 10;

  bool _canContinue(OnboardingState s) {
    switch (_currentPage) {
      case 1:
        return s.ageRange != null;
      case 2:
        return s.identities.isNotEmpty;
      case 3:
        return s.feelings.isNotEmpty;
      case 4:
        return s.lifeRatings.length >= _lifeDimensions(context).length;
      case 8:
        return (s.name ?? '').trim().isNotEmpty;
      case 9:
        return s.tone != null;
      default:
        return true;
    }
  }

  // Education pages carry their own CTA label; everything else says "Continue".
  String _continueLabel(AppLocalizations l10n) {
    switch (_currentPage) {
      case 5:
        return l10n.onboardingAppyProblemCta;
      case 6:
        return l10n.onboardingAppySolutionCta;
      default:
        return l10n.onboardingContinue;
    }
  }

  // --- Auth routing -------------------------------------------------------

  Future<void> _completeFlow() async {
    final cubit = context.read<OnboardingCubit>();
    final subscription = context.read<SubscriptionCubit>();
    setState(() => _finalizing = true);
    try {
      await cubit.completeOnboarding(subscription);
    } finally {
      if (mounted) {
        setState(() => _finalizing = false);
        cubit.finishOnboarding();
      }
    }
  }

  // --- Page content -------------------------------------------------------

  static List<LifeDimension> _lifeDimensions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      LifeDimension('health', l10n.onboardingAppyLifeHealth),
      LifeDimension('support', l10n.onboardingAppyLifeSupport),
      LifeDimension('safety', l10n.onboardingAppyLifeSafety),
      LifeDimension('environment', l10n.onboardingAppyLifeEnvironment),
      LifeDimension('selfCare', l10n.onboardingAppyLifeSelfCare),
      LifeDimension('enjoyment', l10n.onboardingAppyLifeEnjoyment),
      LifeDimension('job', l10n.onboardingAppyLifeJob),
      LifeDimension('meaning', l10n.onboardingAppyLifeMeaning),
    ];
  }

  List<Widget> _pages(OnboardingState state, OnboardingCubit cubit,
      AppLocalizations l10n) {
    return [
      // 0: privacy education
      EducationStep(
        emoji: '🔒',
        title: l10n.onboardingAppyPrivacyTitle,
        footnote: l10n.onboardingAppyPrivacyFootnote,
      ),
      // 1: age
      SurveyStep(
        question: l10n.onboardingAppyAgeQuestion,
        options: [
          l10n.onboardingAppyAgeUnder18,
          l10n.onboardingAppyAge1824,
          l10n.onboardingAppyAge2534,
          l10n.onboardingAppyAge3544,
          l10n.onboardingAppyAge4554,
          l10n.onboardingAppyAge55,
        ],
        selectedOption: state.ageRange,
        onSelected: cubit.setAge,
      ),
      // 2: identity (multi-select)
      MultiSelectStep(
        question: l10n.onboardingAppyIdentityQuestion,
        subtitle: l10n.onboardingAppyMultiSelectHint,
        selected: state.identities,
        onToggle: cubit.toggleIdentity,
        options: [
          MultiSelectOption(
              value: 'woman', emoji: '👩', label: l10n.onboardingAppyIdentityWoman),
          MultiSelectOption(
              value: 'man', emoji: '👨', label: l10n.onboardingAppyIdentityMan),
          MultiSelectOption(
              value: 'nonBinary',
              emoji: '🧑',
              label: l10n.onboardingAppyIdentityNonBinary),
          MultiSelectOption(
              value: 'transgender',
              emoji: '🏳️‍⚧️',
              label: l10n.onboardingAppyIdentityTrans),
          MultiSelectOption(
              value: 'preferNot',
              emoji: '🤐',
              label: l10n.onboardingAppyIdentityPreferNot),
          MultiSelectOption(
              value: 'other', emoji: '✨', label: l10n.onboardingAppyIdentityOther),
        ],
      ),
      // 3: feelings (multi-select)
      MultiSelectStep(
        question: l10n.onboardingAppyFeelingsQuestion,
        subtitle: l10n.onboardingAppyMultiSelectHint,
        selected: state.feelings,
        onToggle: cubit.toggleFeeling,
        options: [
          MultiSelectOption(
              value: 'tired', emoji: '😮‍💨', label: l10n.onboardingAppyFeelingTired),
          MultiSelectOption(
              value: 'anxious', emoji: '😰', label: l10n.onboardingAppyFeelingAnxious),
          MultiSelectOption(
              value: 'lonely', emoji: '🥺', label: l10n.onboardingAppyFeelingLonely),
          MultiSelectOption(
              value: 'stuck', emoji: '🧭', label: l10n.onboardingAppyFeelingStuck),
          MultiSelectOption(
              value: 'down', emoji: '🌧️', label: l10n.onboardingAppyFeelingDown),
          MultiSelectOption(
              value: 'hardOnSelf',
              emoji: '🪞',
              label: l10n.onboardingAppyFeelingHardOnSelf),
          MultiSelectOption(
              value: 'overwhelmed',
              emoji: '🌊',
              label: l10n.onboardingAppyFeelingOverwhelmed),
          MultiSelectOption(
              value: 'good', emoji: '🙂', label: l10n.onboardingAppyFeelingGood),
          MultiSelectOption(
              value: 'other', emoji: '✨', label: l10n.onboardingAppyFeelingOther),
        ],
      ),
      // 4: rate life dimensions
      LifeRatingStep(
        title: l10n.onboardingAppyLifeTitle,
        subtitle: l10n.onboardingAppyLifeSubtitle,
        dimensions: _lifeDimensions(context),
        ratings: state.lifeRatings,
        onRate: cubit.setRating,
      ),
      // 5: problem (education)
      EducationStep(
        emoji: '🌫️',
        title: l10n.onboardingAppyProblemTitle,
        body: l10n.onboardingAppyProblemBody,
      ),
      // 6: solution (education)
      EducationStep(
        emoji: '💬',
        title: l10n.onboardingAppySolutionTitle,
        body: l10n.onboardingAppySolutionBody,
      ),
      // 7: present Appy (education)
      EducationStep(
        emoji: '👋',
        title: l10n.onboardingAppyPresentTitle,
        body: l10n.onboardingAppyPresentBody,
        footnote: l10n.onboardingAppyPresentFootnote,
      ),
      // 8: name
      NameInputStep(
        title: l10n.onboardingAppyNameQuestion,
        hint: l10n.onboardingAppyNameHint,
        initialValue: state.name,
        onChanged: cubit.setName,
      ),
      // 9: tone
      SurveyStep(
        question: l10n.onboardingAppyToneQuestion,
        options: [
          l10n.onboardingAppyToneExploration,
          l10n.onboardingAppyToneValidate,
          l10n.onboardingAppyToneChallenging,
          l10n.onboardingAppyToneSolution,
        ],
        selectedOption: state.tone,
        onSelected: cubit.setTone,
      ),
      // 10: sign up → complete
      OnboardingAuthStep(
        mode: OnboardingAuthMode.signUp,
        title: l10n.onboardingAppySignUpTitle,
        subtitle: l10n.onboardingAppySignUpSubtitle,
        onAuthenticated: _completeFlow,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final cubit = context.read<OnboardingCubit>();
        final fraction =
            (_currentPage / (_totalPages - 1)).clamp(0.0, 1.0);

        return Scaffold(
          backgroundColor: c.background,
          body: Stack(
            children: [
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Header: a centered progress bar with equal side zones so
                    // its position never shifts, the circular back button on
                    // the left, and the language selector pinned to the right.
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
                      child: Row(
                        children: [
                          // Left zone mirrors the right zone to keep the bar
                          // centered; holds the back button when available.
                          SizedBox(
                            width: 52.w,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: (_currentPage > 0 &&
                                      !_ownsNav(_currentPage))
                                  ? GestureDetector(
                                      onTap: withHaptic(_back),
                                      child: Container(
                                        width: 50.w,
                                        height: 50.h,
                                        decoration: BoxDecoration(
                                          color: c.card,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                            Icons.chevron_left_rounded,
                                            size: 30.sp,
                                            color: c.textPrimary),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          SizedBox(width: 24.w),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4.r),
                              child: LinearProgressIndicator(
                                value: fraction,
                                minHeight: 6,
                                backgroundColor: c.separator,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(c.primary),
                              ),
                            ),
                          ),
                          SizedBox(width: 24.w),
                          // Right zone: language selector, always available.
                          SizedBox(
                            width: 52.w,
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: LanguageFlagButton(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: _pages(state, cubit, l10n),
                      ),
                    ),
                    if (!_ownsNav(_currentPage))
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
                          child: SizedBox(
                            width: double.infinity,
                            height: 56.h,
                            child: ElevatedButton(
                              onPressed: _canContinue(state)
                                  ? withHaptic(_next)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: c.textPrimary,
                                foregroundColor: c.card,
                                disabledBackgroundColor: c.separator,
                                disabledForegroundColor: c.textSecondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28.r),
                                ),
                              ),
                              child: Text(
                                _continueLabel(l10n),
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (_finalizing)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
