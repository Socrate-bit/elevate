import 'package:equatable/equatable.dart';

enum ReferralStatus { none, checking, valid, invalid, exhausted }

class OnboardingState extends Equatable {
  final int currentPage;
  final Map<String, String> surveyAnswers;
  final String referralCode;
  final ReferralStatus referralStatus;
  final bool isInProgress;
  final bool isComplete;

  // v2 (Appy) onboarding answers. See OnboardingScreenV2.
  final String? ageRange;
  final Set<String> identities;
  final Set<String> feelings;
  final Map<String, int> lifeRatings;
  final String? name;
  final String? petName;
  final String? tone;

  const OnboardingState({
    this.currentPage = 0,
    this.surveyAnswers = const {},
    this.referralCode = '',
    this.referralStatus = ReferralStatus.none,
    this.isInProgress = false,
    this.isComplete = false,
    this.ageRange,
    this.identities = const {},
    this.feelings = const {},
    this.lifeRatings = const {},
    this.name,
    this.petName,
    this.tone,
  });

  OnboardingState copyWith({
    int? currentPage,
    Map<String, String>? surveyAnswers,
    String? referralCode,
    ReferralStatus? referralStatus,
    bool? isInProgress,
    bool? isComplete,
    String? ageRange,
    Set<String>? identities,
    Set<String>? feelings,
    Map<String, int>? lifeRatings,
    String? name,
    String? petName,
    String? tone,
  }) =>
      OnboardingState(
        currentPage: currentPage ?? this.currentPage,
        surveyAnswers: surveyAnswers ?? this.surveyAnswers,
        referralCode: referralCode ?? this.referralCode,
        referralStatus: referralStatus ?? this.referralStatus,
        isInProgress: isInProgress ?? this.isInProgress,
        isComplete: isComplete ?? this.isComplete,
        ageRange: ageRange ?? this.ageRange,
        identities: identities ?? this.identities,
        feelings: feelings ?? this.feelings,
        lifeRatings: lifeRatings ?? this.lifeRatings,
        name: name ?? this.name,
        petName: petName ?? this.petName,
        tone: tone ?? this.tone,
      );

  @override
  List<Object?> get props => [
        currentPage,
        surveyAnswers,
        referralCode,
        referralStatus,
        isInProgress,
        isComplete,
        ageRange,
        identities,
        feelings,
        lifeRatings,
        name,
        petName,
        tone,
      ];
}
