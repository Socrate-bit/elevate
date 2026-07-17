import 'package:equatable/equatable.dart';

enum ReferralStatus { none, checking, valid, invalid, exhausted }

class OnboardingState extends Equatable {
  final int currentPage;
  final Map<String, String> surveyAnswers;
  final String referralCode;
  final ReferralStatus referralStatus;
  final String username;
  final bool isInProgress;
  final bool isComplete;

  const OnboardingState({
    this.currentPage = 0,
    this.surveyAnswers = const {},
    this.referralCode = '',
    this.referralStatus = ReferralStatus.none,
    this.username = '',
    this.isInProgress = false,
    this.isComplete = false,
  });

  OnboardingState copyWith({
    int? currentPage,
    Map<String, String>? surveyAnswers,
    String? referralCode,
    ReferralStatus? referralStatus,
    String? username,
    bool? isInProgress,
    bool? isComplete,
  }) =>
      OnboardingState(
        currentPage: currentPage ?? this.currentPage,
        surveyAnswers: surveyAnswers ?? this.surveyAnswers,
        referralCode: referralCode ?? this.referralCode,
        referralStatus: referralStatus ?? this.referralStatus,
        username: username ?? this.username,
        isInProgress: isInProgress ?? this.isInProgress,
        isComplete: isComplete ?? this.isComplete,
      );

  @override
  List<Object?> get props => [
        currentPage,
        surveyAnswers,
        referralCode,
        referralStatus,
        username,
        isInProgress,
        isComplete,
      ];
}
