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

  /// Exits the funnel back to the start screen without completing it.
  /// AuthWrapper shows [OnboardingStartScreen] again while progress is false.
  void backToStart() {
    if (!state.isInProgress) return;
    emit(state.copyWith(isInProgress: false));
    debugPrint('[OnboardingCubit] back to start screen');
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

  // --- v2 (Appy) onboarding answers -------------------------------------

  void setAge(String value) {
    emit(state.copyWith(ageRange: value));
    _captureAnswer('age', value);
  }

  void toggleIdentity(String value) {
    // Single selection: tapping a new value replaces the current one; tapping
    // the selected value again clears it.
    final next = state.identities.contains(value) ? <String>{} : {value};
    emit(state.copyWith(identities: next));
    _captureAnswer('identities', next.join(', '));
  }

  void toggleFeeling(String value) {
    final next = {...state.feelings};
    next.contains(value) ? next.remove(value) : next.add(value);
    emit(state.copyWith(feelings: next));
    _captureAnswer('feelings', next.join(', '));
  }

  void setRating(String dimension, int value) {
    emit(state.copyWith(
      lifeRatings: {...state.lifeRatings, dimension: value},
    ));
    _captureAnswer('life_rating_$dimension', '$value');
  }

  void setName(String value) => emit(state.copyWith(name: value));

  void setPetName(String value) {
    emit(state.copyWith(petName: value));
    _captureAnswer('pet_name', value);
  }

  void setTone(String value) {
    emit(state.copyWith(tone: value));
    _captureAnswer('tone', value);
  }

  void _captureAnswer(String key, String value) {
    AnalyticsService.capture(
      AnalyticsService.onboardingStep,
      {'step_name': 'survey_$key', 'value': value},
    );
  }

  /// Whether the currently signed-in user already finished onboarding. Used by
  /// the early sign-in step to route returning users straight to the app.
  Future<bool> hasCompletedOnboarding() async {
    final uid = AuthService.uidOrNull;
    if (uid == null) return false;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('meta')
          .doc('onboarding')
          .get();
      return doc.data()?['onboardingComplete'] == true;
    } catch (e) {
      debugPrint('[OnboardingCubit] hasCompletedOnboarding check failed: $e');
      return false;
    }
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
          if (state.ageRange != null) 'ageRange': state.ageRange,
          if (state.identities.isNotEmpty)
            'identities': state.identities.toList(),
          if (state.feelings.isNotEmpty) 'feelings': state.feelings.toList(),
          if (state.lifeRatings.isNotEmpty) 'lifeRatings': state.lifeRatings,
          if (state.name != null && state.name!.trim().isNotEmpty)
            'name': state.name!.trim(),
          if (state.petName != null && state.petName!.trim().isNotEmpty)
            'petName': state.petName!.trim(),
          if (state.tone != null) 'tone': state.tone,
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
