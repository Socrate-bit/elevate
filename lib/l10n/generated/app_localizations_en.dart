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
  String get navChat => 'Chat';

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
  String get onboardingLoadingStep1 => 'Task 1';

  @override
  String get onboardingLoadingStep2 => 'Task 2';

  @override
  String get onboardingLoadingStep3 => 'Task 3';

  @override
  String get onboardingLoadingStep4 => 'Task 4';

  @override
  String get onboardingLoadingStep5 => 'Task 5';

  @override
  String get onboardingLoadingStep6 => 'Task 6';

  @override
  String get onboardingAgeRangeQuestion => 'What\'s your age range?';

  @override
  String get onboardingGenderQuestion => 'How do you identify?';

  @override
  String get onboardingWhereHeard => 'Where did you hear about us?';

  @override
  String get onboardingYouTube => 'YouTube';

  @override
  String get onboardingFacebook => 'Facebook';

  @override
  String get onboardingTwitter => 'X (Twitter)';

  @override
  String get onboardingReddit => 'Reddit';

  @override
  String get onboardingAppStore => 'App Store';

  @override
  String get onboardingFriendFamily => 'Friend or family';

  @override
  String get onboardingOther => 'Other';

  @override
  String get onboardingTimePickerTitle => 'Pick a time';

  @override
  String get onboardingTimePickerSubtitle => 'Replace with your prompt.';

  @override
  String get onboardingDayPickerTitle => 'Which days?';

  @override
  String get onboardingDayPickerSubtitle => 'Pick the days that work for you.';

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

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatModelName => 'Gemini';

  @override
  String get chatHistoryTitle => 'Conversations';

  @override
  String get chatHistorySearchHint => 'Search';

  @override
  String get chatHistoryEmpty => 'No conversations yet';

  @override
  String get chatHistoryEmptyHint => 'Tap + to start a new chat.';

  @override
  String get chatGreeting => 'How can I help you tonight?';

  @override
  String get chatStartChat => 'Start chat';

  @override
  String get chatComposerHint => 'Message';

  @override
  String get chatSend => 'Send';

  @override
  String get chatNewConversation => 'New chat';

  @override
  String get chatUntitledConversation => 'New conversation';

  @override
  String get chatVoiceListening => 'Listening…';

  @override
  String get chatVoiceUnavailable => 'Voice input is unavailable.';

  @override
  String get chatVoicePermissionDenied => 'Microphone permission denied.';

  @override
  String get chatSendFailed => 'Couldn\'t send message. Please try again.';

  @override
  String get chatDelete => 'Delete';

  @override
  String get chatDeleteConfirm => 'Delete this conversation?';

  @override
  String get chatDeleteCancel => 'Cancel';

  @override
  String get chatRelativeJustNow => 'just now';

  @override
  String chatRelativeSecondsAgo(int n) {
    return '$n seconds ago';
  }

  @override
  String chatRelativeMinutesAgo(int n) {
    return '$n minutes ago';
  }

  @override
  String chatRelativeHoursAgo(int n) {
    return '$n hours ago';
  }

  @override
  String chatRelativeDaysAgo(int n) {
    return '$n days ago';
  }

  @override
  String get chatMissionStart => 'Start Mission';

  @override
  String get chatMissionDecline => 'Not now';

  @override
  String get chatMissionAccepted => 'Mission started';

  @override
  String get chatMissionDeclined => 'Maybe later';

  @override
  String get chatMissionValidated => 'I just finished the mission!';

  @override
  String get chatMissionSetUp => 'Set up this mission';

  @override
  String get dismissMissionTimeToWakeUp => 'Time to wake up!';

  @override
  String dismissMissionLabel(int n, int total, String name) {
    return 'Mission $n of $total: $name';
  }

  @override
  String get dismissStartMission => 'Start Mission';

  @override
  String dismissMathProgress(int n, int total) {
    return 'Problem $n of $total';
  }

  @override
  String get dismissMathWrong => 'Wrong, try again';

  @override
  String get dismissMathConfirm => 'Check';

  @override
  String get dismissShakePrompt => 'Shake your phone!';

  @override
  String dismissSpeechTryAgain(int score) {
    return 'Try again: $score%';
  }

  @override
  String dismissSpeechProgress(int n, int total) {
    return 'Affirmation $n of $total';
  }

  @override
  String get dismissSpeechSay => 'Say this aloud:';

  @override
  String get dismissSpeechListening => 'Listening…';

  @override
  String get dismissSpeechTapToSpeak => 'Tap to speak';

  @override
  String get dismissSpeechMicUnavailable => 'Microphone unavailable';

  @override
  String dismissPhotoPrompt(String target) {
    return 'Find: $target';
  }

  @override
  String dismissPhotoNotDetected(String target) {
    return 'Couldn\'t detect $target';
  }

  @override
  String dismissPhotoError(String error) {
    return 'Error: $error';
  }

  @override
  String dismissPhotoChecking(String target) {
    return 'Checking for $target…';
  }

  @override
  String get dismissPhotoStarting => 'Starting camera…';

  @override
  String get dismissPhotoPickingTarget => 'Picking your target…';

  @override
  String get dismissFeedbackMoveIntoFrame => 'Move into frame';

  @override
  String get dismissFeedbackKeepGoing => 'Keep going!';

  @override
  String get dismissFeedbackPushupPosition => 'Get in push-up position';

  @override
  String get dismissFeedbackStartPushups => 'Start push-ups';

  @override
  String get dismissFeedbackPushupGoDeeper => 'Go deeper';

  @override
  String get dismissFeedbackSquatPosition => 'Keep knees over ankles';

  @override
  String get dismissFeedbackStartSquats => 'Start squats';

  @override
  String get dismissFeedbackSquatGoDeeper => 'Squat deeper';

  @override
  String get dismissRepStarting => 'Starting camera…';

  @override
  String dismissRepPrompt(int count, String name) {
    return 'Do $count $name';
  }

  @override
  String dismissRepOf(int target) {
    return 'of $target';
  }

  @override
  String get missionComplete => 'Mission Complete!';

  @override
  String get missionCompleteMessage => 'Great job! Keep it up.';

  @override
  String get missionPickerTitle => 'Missions';

  @override
  String get missionPickerSubtitle => 'Pick a mission and start now';

  @override
  String get breathingPhaseInhale => 'Inhale';

  @override
  String get breathingPhaseHold => 'Hold';

  @override
  String get breathingPhaseExhale => 'Exhale';

  @override
  String breathingRoundLabel(int current, int total) {
    return 'Round $current / $total';
  }

  @override
  String get toolSessionDone => 'Done';

  @override
  String get toolSessionLoadError => 'Couldn\'t load. Tap to retry.';

  @override
  String get gratitudeTitle => 'Gratitude';

  @override
  String get gratitudeStepPrompt =>
      'What are 3 things this week that gave you joy?';

  @override
  String get gratitudeHint => 'It can be as simple as a good meal…';

  @override
  String gratitudeJoyLabel(int number) {
    return 'Joy $number';
  }

  @override
  String get gratitudeRememberTitle => 'Take a moment';

  @override
  String get gratitudeRememberBody =>
      'Remember each one, and relive the feeling it gave you.';

  @override
  String get gratitudeAffirmTitle => 'Be grateful';

  @override
  String get gratitudeAffirmBody =>
      'Hold gratitude for these moments — let it settle in.';

  @override
  String get gratitudeContinue => 'Continue';

  @override
  String get gratitudeDone => 'Done';

  @override
  String get gratitudeSaveError => 'Couldn\'t save. Please try again.';

  @override
  String get moodPickerTitle => 'How are you?';

  @override
  String get moodPickerRad => 'rad';

  @override
  String get moodPickerGood => 'good';

  @override
  String get moodPickerMeh => 'meh';

  @override
  String get moodPickerBad => 'bad';

  @override
  String get moodPickerAwful => 'awful';

  @override
  String get moodSectionTitle => 'Mood';

  @override
  String get homeActionsTitle => 'Actions';

  @override
  String get homeActionsEmpty => 'No actions yet. Tap + to add one.';

  @override
  String get homeHabitsTitle => 'Habits';

  @override
  String get homeHabitsEmpty => 'No habits yet. Tap + to add one.';

  @override
  String get homeAddTitle => 'What\'s next?';

  @override
  String get homeAddMoodDesc => 'Log your mood';

  @override
  String get homeAddMissionDesc => 'Start a quick mission';

  @override
  String get routinePickerTitle => 'What do you want to add?';

  @override
  String get routinePickerSubtitle => 'Actions are one-shot. Habits repeat.';

  @override
  String get routineTypeAction => 'Action';

  @override
  String get routineTypeActionDesc => 'A one-time task.';

  @override
  String get routineTypeHabit => 'Habit';

  @override
  String get routineTypeHabitDesc => 'Repeats on chosen days.';

  @override
  String get routineFormNewAction => 'New action';

  @override
  String get routineFormNewHabit => 'New habit';

  @override
  String get routineFormEditTitle => 'Edit';

  @override
  String get routineFormCreate => 'Create';

  @override
  String get routineFormNameHint => 'Name';

  @override
  String get routineFormDescriptionHint => 'Description (optional)';

  @override
  String get routineFormColorLabel => 'Color';

  @override
  String get routineFormEmojiLabel => 'Choose an emoji';

  @override
  String get routineFormXpLabel => 'Reward';

  @override
  String get routineFormObjectCheckLabel => 'Object check';

  @override
  String get routineFormObjectCheckHint =>
      'e.g. toothbrush, book, water bottle';

  @override
  String get routineFormDateLabel => 'Date';

  @override
  String get routineFormPickDate => 'Pick a date';

  @override
  String get routineFormPickTime => 'Pick a time';

  @override
  String get routineFormClear => 'Clear';

  @override
  String get routineFormAlarmLabel => 'Ring an alarm';

  @override
  String get routineFormAlarmHint => 'Plays when the time arrives.';

  @override
  String get routineFormDeleteTitle => 'Delete routine?';

  @override
  String get routineFormDeleteMessage =>
      'This will remove it from your tracker.';

  @override
  String get routineFormDeleteCancel => 'Cancel';

  @override
  String get routineFormDeleteConfirm => 'Delete';

  @override
  String get routineCardTapToValidate => 'Tap to validate';

  @override
  String routineCardObjectCheck(String object) {
    return 'Photo check: $object';
  }

  @override
  String get routineHabitNoSchedule => 'No schedule';

  @override
  String chatRoutineCreated(String name) {
    return 'Created \'$name\'';
  }

  @override
  String chatRoutineUpdated(String name) {
    return 'Updated \'$name\'';
  }

  @override
  String chatRoutineDeleted(String name) {
    return 'Deleted \'$name\'';
  }

  @override
  String get chatActionStartNow => 'Start now';

  @override
  String get chatActionDone => 'Done';

  @override
  String get chatActionCompleted => 'I just completed it!';

  @override
  String homePageGreeting(String name) {
    return 'Good afternoon, $name 🌿';
  }

  @override
  String get homePageHeadline => 'You\'re doing great today!';

  @override
  String get homePageMessage => 'Message';

  @override
  String get homePageCall => 'Call';

  @override
  String get homePageCrisisMode => 'Crisis Mode';

  @override
  String homePageQuestProgress(int done, int total) {
    return '$done / $total';
  }

  @override
  String get homePageTodaysPlan => 'Today\'s Plan';

  @override
  String get homePageTodaysPlanSubtitle => 'Small steps, big changes.';

  @override
  String get homePagePlanEmpty =>
      'Nothing planned for today. Tap + to add a task.';

  @override
  String get homePageEdit => 'Edit';

  @override
  String homePageXp(int xp) {
    return '+ $xp XP';
  }

  @override
  String get navJournal => 'Journal';

  @override
  String get navTools => 'Tools';

  @override
  String get chatPageCalmMode => 'Calm mode';

  @override
  String get chatPageCompanionName => 'Appy';

  @override
  String get chatPageCompanionSubtitle => 'Your mindful companion';

  @override
  String get chatPageToday => 'Today';

  @override
  String get chatPageYesterday => 'Yesterday';

  @override
  String get chatPageStartConversation => 'Start a conversation';

  @override
  String get chatPageSuggestTalkDay => 'Talk about my day';

  @override
  String get chatPageSuggestComfort => 'I need comfort';

  @override
  String get chatPageSuggestReflect => 'Help me reflect';

  @override
  String get chatPageComposerHint => 'Your message';

  @override
  String get journalTitle => 'Journal';

  @override
  String get journalMonthlyInsight => 'Monthly Insight';

  @override
  String get journalInputCues => 'Input Cues';
}
