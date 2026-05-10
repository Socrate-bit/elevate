// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Skeleton';

  @override
  String get generalOk => 'OK';

  @override
  String get generalDefault => 'Default';

  @override
  String get navHome => 'Home';

  @override
  String get navInsights => 'Insights';

  @override
  String get navSettings => 'Settings';

  @override
  String get daySingleSun => 'S';

  @override
  String get daySingleMon => 'M';

  @override
  String get daySingleTue => 'T';

  @override
  String get daySingleWed => 'W';

  @override
  String get daySingleThu => 'T';

  @override
  String get daySingleFri => 'F';

  @override
  String get daySingleSat => 'S';

  @override
  String get daySun => 'Sun';

  @override
  String get dayMon => 'Mon';

  @override
  String get dayTue => 'Tue';

  @override
  String get dayWed => 'Wed';

  @override
  String get dayThu => 'Thu';

  @override
  String get dayFri => 'Fri';

  @override
  String get daySat => 'Sat';

  @override
  String get daySundayFull => 'Sunday';

  @override
  String get dayMondayFull => 'Monday';

  @override
  String get dayTuesdayFull => 'Tuesday';

  @override
  String get dayWednesdayFull => 'Wednesday';

  @override
  String get dayThursdayFull => 'Thursday';

  @override
  String get dayFridayFull => 'Friday';

  @override
  String get daySaturdayFull => 'Saturday';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Apr';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Aug';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dec';

  @override
  String get alarmStop => 'Stop';

  @override
  String get alarmsTitle => 'Alarms';

  @override
  String get alarmsEmpty => 'No alarms yet';

  @override
  String get alarmsEmptyHint => 'Tap + to add one.';

  @override
  String get alarmsOneTime => 'One-time';

  @override
  String get alarmsEveryDay => 'Every day';

  @override
  String get alarmsWeekdays => 'Weekdays';

  @override
  String alarmsDefaultName(int n) {
    return 'Alarm #$n';
  }

  @override
  String get alarmFormNewAlarm => 'New alarm';

  @override
  String get alarmFormEditAlarm => 'Edit alarm';

  @override
  String get alarmFormAlarmName => 'Alarm name';

  @override
  String get alarmFormAlarmTime => 'Time';

  @override
  String get alarmFormSetTime => 'Set time';

  @override
  String get alarmFormDone => 'Done';

  @override
  String get alarmFormScheduled => 'Scheduled';

  @override
  String get alarmFormOneTime => 'One-time';

  @override
  String get alarmFormRepeatOn => 'Repeat on';

  @override
  String get alarmFormCreateAlarm => 'Create alarm';

  @override
  String get alarmFormSaveChanges => 'Save changes';

  @override
  String get homeNextAlarm => 'Next alarm';

  @override
  String get homeToday => 'Today';

  @override
  String get homeTomorrow => 'Tomorrow';

  @override
  String get homePastAlarm => 'Already past';

  @override
  String homeRingsIn(int h, int m) {
    return 'Rings in ${h}h ${m}m';
  }

  @override
  String get homeNoActiveAlarm => 'No active alarm';

  @override
  String get homeNoActiveAlarmHint => 'Tap to add one.';

  @override
  String get activityHistoryTitle => 'Activity';

  @override
  String get activityHistoryEmpty => 'No activity yet';

  @override
  String get activityHistoryMissed => 'Missed';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get insightsWeek => 'Week';

  @override
  String get insightsMonth => 'Month';

  @override
  String get insightsAllTime => 'All time';

  @override
  String get insightsStats => 'Stats';

  @override
  String get insightsAvgTime => 'Avg time';

  @override
  String get insightsAvgDuration => 'Avg duration';

  @override
  String get insightsDayStreak => 'Day streak';

  @override
  String get insightsBadgesEarned => 'Badges earned';

  @override
  String get milestonesTitle => 'Milestones';

  @override
  String get milestonesDayStreak => 'Day streak';

  @override
  String get milestonesBadgesEarned => 'Badges earned';

  @override
  String milestonesLongestStreak(int n) {
    return '$n';
  }

  @override
  String get milestonesLongestStreakLabel => 'Longest streak';

  @override
  String get milestonesStreakBadges => 'Streak badges';

  @override
  String get milestonesAchievementBadges => 'Challenges';

  @override
  String get milestonesHowStreaksWork => 'How streaks work';

  @override
  String get milestonesStreakExplanation =>
      'Log an activity each day to keep your streak alive. Up to 2 missed days per week count as freezes and don\'t break the streak.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsApp => 'App';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsDevTools => 'Dev tools';

  @override
  String get settingsDevToolsEmpty => 'Add per-project dev tools here.';

  @override
  String get settingsUserType => 'Plan';

  @override
  String get settingsEnterReferralCode => 'Enter referral code';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsDarkMode => 'Dark mode';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsTermsOfService => 'Terms of service';

  @override
  String get settingsLogout => 'Log out';

  @override
  String get settingsLogoutTitle => 'Log out?';

  @override
  String get settingsLogoutBody => 'You can sign back in any time.';

  @override
  String get settingsLogoutCancel => 'Cancel';

  @override
  String get settingsLogoutConfirm => 'Log out';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsDeleteAccountTitle => 'Delete account?';

  @override
  String get settingsDeleteAccountBody =>
      'This permanently removes your data. This cannot be undone.';

  @override
  String get settingsDeleteAccountCancel => 'Cancel';

  @override
  String get settingsDeleteAccountConfirm => 'Delete';

  @override
  String get settingsDeleteAccountError =>
      'Couldn\'t delete account. Please try again.';

  @override
  String get settingsDeleteAccountReauthRequired =>
      'Please sign in again before deleting your account.';

  @override
  String get settingsVersion => 'v0.1.0';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Skeleton';

  @override
  String get onboardingWelcomeSubtitle =>
      'Replace this with a welcome message about your app.';

  @override
  String get onboardingInfoTitle => 'Info page 1';

  @override
  String get onboardingInfoBody =>
      'Replace this with a meaningful info page body. Lorem ipsum dolor sit amet.';

  @override
  String get onboardingNotificationTitle => 'Stay in the loop';

  @override
  String get onboardingNotificationBody =>
      'Allow notifications so we can ping you when it matters.';

  @override
  String get onboardingEnableNotifications => 'Enable notifications';

  @override
  String get onboardingMaybeLater => 'Maybe later';

  @override
  String get onboardingSignatureTitle => 'Sign your commitment';

  @override
  String get onboardingSignatureBody => 'Sign below to confirm you\'re in.';

  @override
  String get onboardingSignatureClear => 'Clear';

  @override
  String get onboardingSignatureCommit => 'I commit';

  @override
  String get onboardingLoadingTitle => 'Preparing your app…';

  @override
  String get onboardingSignInTitle => 'Create your account';

  @override
  String get onboardingSignInSubtitle =>
      'Save your progress and sync across devices.';

  @override
  String get onboardingSignInApple => 'Continue with Apple';

  @override
  String get onboardingSignInGoogle => 'Continue with Google';

  @override
  String get onboardingSignInEmail => 'Continue with email';

  @override
  String get onboardingSkipForNow => 'Skip for now';

  @override
  String get onboardingAccountNotFound => 'No account found for that sign-in.';

  @override
  String get onboardingGoogleFailed =>
      'Google sign-in failed. Please try again.';

  @override
  String get onboardingAppleFailed => 'Apple sign-in failed. Please try again.';

  @override
  String get onboardingEmailLabel => 'Email';

  @override
  String get onboardingPasswordLabel => 'Password';

  @override
  String get onboardingEmailEmptyError =>
      'Please enter your email and password.';

  @override
  String get onboardingEmailModalSignInTitle => 'Sign in';

  @override
  String get onboardingEmailModalSignUpTitle => 'Sign up';

  @override
  String get onboardingEmailSignInAction => 'Sign in';

  @override
  String get onboardingEmailSignUpAction => 'Sign up';

  @override
  String get onboardingEmailHasAccount => 'Already have an account? Sign in';

  @override
  String get onboardingEmailNoAccount => 'No account yet? Sign up';

  @override
  String get onboardingPaywallTitle => 'Try the full app free';

  @override
  String get onboardingPaywallTryFree => 'Start free trial';

  @override
  String get onboardingPaywallNoPayment => 'No payment due now';

  @override
  String get onboardingPaywallNoCommitment => 'Cancel anytime';

  @override
  String get onboardingPaywallPrivacy => 'Privacy';

  @override
  String get onboardingPaywallTerms => 'Terms';

  @override
  String get onboardingPaywallRestore => 'Restore';

  @override
  String get onboardingPaywallEula => 'EULA';

  @override
  String get onboardingTrialTitle => 'We\'ll remind you before billing';

  @override
  String get onboardingTrialNoPayment => 'No payment due now';

  @override
  String get onboardingTrialContinueFree => 'Continue for free';

  @override
  String get onboardingTrialPrice => 'Then \$0.00 / month';

  @override
  String get onboardingReferralTitle => 'Have a referral code?';

  @override
  String get onboardingReferralSubtitle =>
      'Enter it now to apply a perk to your account.';

  @override
  String get onboardingReferralLabel => 'Referral code';

  @override
  String get onboardingReferralApplied => 'Referral applied!';

  @override
  String get onboardingReferralInvalid => 'That code isn\'t valid.';

  @override
  String get onboardingReferralLimit =>
      'That code has reached its usage limit.';

  @override
  String get onboardingRatingTitle => 'Loved by users';

  @override
  String get onboardingRatingSubtitle => 'Read what others have to say.';

  @override
  String get onboardingRatingMarc => 'Marc';

  @override
  String get onboardingRatingMarcReview =>
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';

  @override
  String get onboardingRatingSophie => 'Sophie';

  @override
  String get onboardingRatingSophieReview =>
      'Sed do eiusmod tempor incididunt ut labore et dolore magna.';

  @override
  String get onboardingRatingAlex => 'Alex';

  @override
  String get onboardingRatingAlexReview =>
      'Ut enim ad minim veniam, quis nostrud exercitation ullamco.';

  @override
  String get referralTitle => 'Enter referral code';

  @override
  String get referralCodeLabel => 'Code';

  @override
  String get referralSubmit => 'Apply';

  @override
  String get referralCancel => 'Cancel';

  @override
  String referralApplied(String plan) {
    return 'Code applied: $plan';
  }

  @override
  String get referralInvalid => 'Invalid code';

  @override
  String get referralUsageLimit => 'Usage limit reached';

  @override
  String get referralError => 'Could not check code. Try again.';
}
