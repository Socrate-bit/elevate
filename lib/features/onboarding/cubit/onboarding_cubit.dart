import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/auth_service.dart';
import '../../subscription/services/analytics_service.dart';
import '../../subscription/services/referral_service.dart';
import '../../subscription/cubit/subscription_cubit.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState());

  /// Marks the onboarding flow as in progress. AuthWrapper uses this to
  /// keep showing OnboardingScreen across reactive auth changes.
  void startOnboarding() {
    if (state.isInProgress) return;
    emit(state.copyWith(isInProgress: true));
    AnalyticsService.capture(
      AnalyticsService.onboardingStep,
      {'step_name': 'start'},
    );
  }

  /// Marks the onboarding flow as finished. AuthWrapper then routes to
  /// AppGateWrapper.
  void finishOnboarding() {
    emit(state.copyWith(isInProgress: false, isComplete: true));
    AnalyticsService.capture(
      AnalyticsService.onboardingStep,
      {'step_name': 'finish'},
    );
  }

  void answerSurvey(String key, String value) {
    emit(state.copyWith(
      surveyAnswers: {...state.surveyAnswers, key: value},
    ));
    AnalyticsService.capture(
      AnalyticsService.onboardingStep,
      {'step_name': 'survey_$key', 'value': value},
    );
  }

  void setReferralCode(String code) {
    emit(state.copyWith(
      referralCode: code,
      referralStatus: ReferralStatus.none,
    ));
  }

  /// Client-side validation only — redemption happens in completeOnboarding.
  Future<void> submitReferralCode() async {
    if (state.referralCode.trim().isEmpty) return;
    emit(state.copyWith(referralStatus: ReferralStatus.checking));
    try {
      final result =
          await ReferralService.validateCode(state.referralCode.trim());
      if (result == null) {
        emit(state.copyWith(referralStatus: ReferralStatus.invalid));
      } else if (result == 'exhausted') {
        emit(state.copyWith(referralStatus: ReferralStatus.exhausted));
      } else {
        emit(state.copyWith(referralStatus: ReferralStatus.valid));
      }
    } catch (e) {
      debugPrint('[OnboardingCubit] referral check failed: $e');
      emit(state.copyWith(referralStatus: ReferralStatus.invalid));
    }
  }

  /// Saves survey answers + onboarding metadata to Firestore, redeems any
  /// validated referral code, and refreshes the user's type. Does NOT flip
  /// [isInProgress]; call [finishOnboarding] after the post-signin steps.
  Future<void> completeOnboarding(SubscriptionCubit subscriptionCubit) async {
    final uid = AuthService.uidOrNull;
    if (uid != null) {
      try {
        final data = <String, dynamic>{
          ...state.surveyAnswers,
          'onboardingComplete': true,
          'completedAt': FieldValue.serverTimestamp(),
        };
        if (state.referralCode.trim().isNotEmpty) {
          data['referralCode'] = state.referralCode.trim();
        }
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('meta')
            .doc('onboarding')
            .set(data);
      } catch (e) {
        debugPrint('[OnboardingCubit] survey save failed: $e');
      }
    }

    if (state.referralStatus == ReferralStatus.valid &&
        state.referralCode.trim().isNotEmpty) {
      try {
        await ReferralService.redeemCode(state.referralCode.trim());
      } catch (e) {
        debugPrint('[OnboardingCubit] referral redeem failed: $e');
      }
    }
    await subscriptionCubit.refreshUserType();
  }
}
