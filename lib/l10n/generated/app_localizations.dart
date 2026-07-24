import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Skeleton'**
  String get appTitle;

  /// No description provided for @generalOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get generalOk;

  /// No description provided for @generalDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get generalDefault;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get navInsights;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @daySingleSun.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get daySingleSun;

  /// No description provided for @daySingleMon.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get daySingleMon;

  /// No description provided for @daySingleTue.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get daySingleTue;

  /// No description provided for @daySingleWed.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get daySingleWed;

  /// No description provided for @daySingleThu.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get daySingleThu;

  /// No description provided for @daySingleFri.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get daySingleFri;

  /// No description provided for @daySingleSat.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get daySingleSat;

  /// No description provided for @daySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySun;

  /// No description provided for @dayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySat;

  /// No description provided for @daySundayFull.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get daySundayFull;

  /// No description provided for @dayMondayFull.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get dayMondayFull;

  /// No description provided for @dayTuesdayFull.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dayTuesdayFull;

  /// No description provided for @dayWednesdayFull.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get dayWednesdayFull;

  /// No description provided for @dayThursdayFull.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dayThursdayFull;

  /// No description provided for @dayFridayFull.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get dayFridayFull;

  /// No description provided for @daySaturdayFull.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get daySaturdayFull;

  /// No description provided for @monthJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthDec;

  /// No description provided for @alarmStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get alarmStop;

  /// No description provided for @alarmsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alarms'**
  String get alarmsTitle;

  /// No description provided for @alarmsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No alarms yet'**
  String get alarmsEmpty;

  /// No description provided for @alarmsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add one.'**
  String get alarmsEmptyHint;

  /// No description provided for @alarmsOneTime.
  ///
  /// In en, this message translates to:
  /// **'One-time'**
  String get alarmsOneTime;

  /// No description provided for @alarmsEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get alarmsEveryDay;

  /// No description provided for @alarmsWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get alarmsWeekdays;

  /// No description provided for @alarmsDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Alarm #{n}'**
  String alarmsDefaultName(int n);

  /// No description provided for @alarmFormNewAlarm.
  ///
  /// In en, this message translates to:
  /// **'New alarm'**
  String get alarmFormNewAlarm;

  /// No description provided for @alarmFormEditAlarm.
  ///
  /// In en, this message translates to:
  /// **'Edit alarm'**
  String get alarmFormEditAlarm;

  /// No description provided for @alarmFormAlarmName.
  ///
  /// In en, this message translates to:
  /// **'Alarm name'**
  String get alarmFormAlarmName;

  /// No description provided for @alarmFormAlarmTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get alarmFormAlarmTime;

  /// No description provided for @alarmFormSetTime.
  ///
  /// In en, this message translates to:
  /// **'Set time'**
  String get alarmFormSetTime;

  /// No description provided for @alarmFormDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get alarmFormDone;

  /// No description provided for @alarmFormScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get alarmFormScheduled;

  /// No description provided for @alarmFormOneTime.
  ///
  /// In en, this message translates to:
  /// **'One-time'**
  String get alarmFormOneTime;

  /// No description provided for @alarmFormRepeatOn.
  ///
  /// In en, this message translates to:
  /// **'Repeat on'**
  String get alarmFormRepeatOn;

  /// No description provided for @alarmFormCreateAlarm.
  ///
  /// In en, this message translates to:
  /// **'Create alarm'**
  String get alarmFormCreateAlarm;

  /// No description provided for @alarmFormSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get alarmFormSaveChanges;

  /// No description provided for @homeNextAlarm.
  ///
  /// In en, this message translates to:
  /// **'Next alarm'**
  String get homeNextAlarm;

  /// No description provided for @homeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeToday;

  /// No description provided for @homeTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get homeTomorrow;

  /// No description provided for @homePastAlarm.
  ///
  /// In en, this message translates to:
  /// **'Already past'**
  String get homePastAlarm;

  /// No description provided for @homeRingsIn.
  ///
  /// In en, this message translates to:
  /// **'Rings in {h}h {m}m'**
  String homeRingsIn(int h, int m);

  /// No description provided for @homeNoActiveAlarm.
  ///
  /// In en, this message translates to:
  /// **'No active alarm'**
  String get homeNoActiveAlarm;

  /// No description provided for @homeNoActiveAlarmHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to add one.'**
  String get homeNoActiveAlarmHint;

  /// No description provided for @activityHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityHistoryTitle;

  /// No description provided for @activityHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get activityHistoryEmpty;

  /// No description provided for @activityHistoryMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get activityHistoryMissed;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTitle;

  /// No description provided for @insightsWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get insightsWeek;

  /// No description provided for @insightsMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get insightsMonth;

  /// No description provided for @insightsAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get insightsAllTime;

  /// No description provided for @insightsStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get insightsStats;

  /// No description provided for @insightsAvgTime.
  ///
  /// In en, this message translates to:
  /// **'Avg time'**
  String get insightsAvgTime;

  /// No description provided for @insightsAvgDuration.
  ///
  /// In en, this message translates to:
  /// **'Avg duration'**
  String get insightsAvgDuration;

  /// No description provided for @insightsDayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day streak'**
  String get insightsDayStreak;

  /// No description provided for @insightsBadgesEarned.
  ///
  /// In en, this message translates to:
  /// **'Badges earned'**
  String get insightsBadgesEarned;

  /// No description provided for @milestonesTitle.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get milestonesTitle;

  /// No description provided for @milestonesDayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day streak'**
  String get milestonesDayStreak;

  /// No description provided for @milestonesBadgesEarned.
  ///
  /// In en, this message translates to:
  /// **'Badges earned'**
  String get milestonesBadgesEarned;

  /// No description provided for @milestonesLongestStreak.
  ///
  /// In en, this message translates to:
  /// **'{n}'**
  String milestonesLongestStreak(int n);

  /// No description provided for @milestonesLongestStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get milestonesLongestStreakLabel;

  /// No description provided for @milestonesStreakBadges.
  ///
  /// In en, this message translates to:
  /// **'Streak badges'**
  String get milestonesStreakBadges;

  /// No description provided for @milestonesAchievementBadges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get milestonesAchievementBadges;

  /// No description provided for @milestonesHowStreaksWork.
  ///
  /// In en, this message translates to:
  /// **'How streaks work'**
  String get milestonesHowStreaksWork;

  /// No description provided for @milestonesStreakExplanation.
  ///
  /// In en, this message translates to:
  /// **'Log an activity each day to keep your streak alive. Up to 2 missed days per week count as freezes and don\'t break the streak.'**
  String get milestonesStreakExplanation;

  /// No description provided for @streakTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakTitle;

  /// No description provided for @streakCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get streakCurrentLabel;

  /// No description provided for @streakBestLabel.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get streakBestLabel;

  /// No description provided for @streakNextBadge.
  ///
  /// In en, this message translates to:
  /// **'Next milestone'**
  String get streakNextBadge;

  /// No description provided for @streakDaysToGo.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day to go} other{{days} days to go}}'**
  String streakDaysToGo(int days);

  /// No description provided for @streakAllMilestonesReached.
  ///
  /// In en, this message translates to:
  /// **'All milestones reached!'**
  String get streakAllMilestonesReached;

  /// No description provided for @streakBadge1Name.
  ///
  /// In en, this message translates to:
  /// **'Risen'**
  String get streakBadge1Name;

  /// No description provided for @streakBadge1Quote.
  ///
  /// In en, this message translates to:
  /// **'The journey of a thousand mornings begins with one alarm.'**
  String get streakBadge1Quote;

  /// No description provided for @streakBadge3Name.
  ///
  /// In en, this message translates to:
  /// **'Ignite'**
  String get streakBadge3Name;

  /// No description provided for @streakBadge3Quote.
  ///
  /// In en, this message translates to:
  /// **'Three days in. The flame is growing.'**
  String get streakBadge3Quote;

  /// No description provided for @streakBadge7Name.
  ///
  /// In en, this message translates to:
  /// **'Horizon'**
  String get streakBadge7Name;

  /// No description provided for @streakBadge7Quote.
  ///
  /// In en, this message translates to:
  /// **'A week of mornings — you\'re rewriting your story.'**
  String get streakBadge7Quote;

  /// No description provided for @streakBadge14Name.
  ///
  /// In en, this message translates to:
  /// **'Aurora'**
  String get streakBadge14Name;

  /// No description provided for @streakBadge14Quote.
  ///
  /// In en, this message translates to:
  /// **'Two weeks of sunrise. Keep chasing the light.'**
  String get streakBadge14Quote;

  /// No description provided for @streakBadge30Name.
  ///
  /// In en, this message translates to:
  /// **'Celestial'**
  String get streakBadge30Name;

  /// No description provided for @streakBadge30Quote.
  ///
  /// In en, this message translates to:
  /// **'A full month of rising. You are unstoppable.'**
  String get streakBadge30Quote;

  /// No description provided for @streakBadge100Name.
  ///
  /// In en, this message translates to:
  /// **'Nebula'**
  String get streakBadge100Name;

  /// No description provided for @streakBadge100Quote.
  ///
  /// In en, this message translates to:
  /// **'One hundred mornings. A new you has been born.'**
  String get streakBadge100Quote;

  /// No description provided for @streakBadge365Name.
  ///
  /// In en, this message translates to:
  /// **'Eternal'**
  String get streakBadge365Name;

  /// No description provided for @streakBadge365Quote.
  ///
  /// In en, this message translates to:
  /// **'A full year of mornings. You are legendary.'**
  String get streakBadge365Quote;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get settingsApp;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsDevTools.
  ///
  /// In en, this message translates to:
  /// **'Dev tools'**
  String get settingsDevTools;

  /// No description provided for @settingsDevToolsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add per-project dev tools here.'**
  String get settingsDevToolsEmpty;

  /// No description provided for @settingsUserType.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get settingsUserType;

  /// No description provided for @settingsEnterReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Enter referral code'**
  String get settingsEnterReferralCode;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get settingsTermsOfService;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get settingsLogoutTitle;

  /// No description provided for @settingsLogoutBody.
  ///
  /// In en, this message translates to:
  /// **'You can sign back in any time.'**
  String get settingsLogoutBody;

  /// No description provided for @settingsLogoutCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsLogoutCancel;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogoutConfirm;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get settingsDeleteAccountTitle;

  /// No description provided for @settingsDeleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes your data. This cannot be undone.'**
  String get settingsDeleteAccountBody;

  /// No description provided for @settingsDeleteAccountCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsDeleteAccountCancel;

  /// No description provided for @settingsDeleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get settingsDeleteAccountConfirm;

  /// No description provided for @settingsDeleteAccountError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete account. Please try again.'**
  String get settingsDeleteAccountError;

  /// No description provided for @settingsDeleteAccountReauthRequired.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again before deleting your account.'**
  String get settingsDeleteAccountReauthRequired;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'v0.1.0'**
  String get settingsVersion;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Skeleton'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replace this with a welcome message about your app.'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Info page 1'**
  String get onboardingInfoTitle;

  /// No description provided for @onboardingInfoBody.
  ///
  /// In en, this message translates to:
  /// **'Replace this with a meaningful info page body. Lorem ipsum dolor sit amet.'**
  String get onboardingInfoBody;

  /// No description provided for @onboardingNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay in the loop'**
  String get onboardingNotificationTitle;

  /// No description provided for @onboardingNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications so we can ping you when it matters.'**
  String get onboardingNotificationBody;

  /// No description provided for @onboardingEnableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get onboardingEnableNotifications;

  /// No description provided for @onboardingMaybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get onboardingMaybeLater;

  /// No description provided for @onboardingSignatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign your commitment'**
  String get onboardingSignatureTitle;

  /// No description provided for @onboardingSignatureBody.
  ///
  /// In en, this message translates to:
  /// **'Sign below to confirm you\'re in.'**
  String get onboardingSignatureBody;

  /// No description provided for @onboardingSignatureClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get onboardingSignatureClear;

  /// No description provided for @onboardingSignatureCommit.
  ///
  /// In en, this message translates to:
  /// **'I commit'**
  String get onboardingSignatureCommit;

  /// No description provided for @onboardingLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Preparing your app…'**
  String get onboardingLoadingTitle;

  /// No description provided for @onboardingLoadingStep1.
  ///
  /// In en, this message translates to:
  /// **'Task 1'**
  String get onboardingLoadingStep1;

  /// No description provided for @onboardingLoadingStep2.
  ///
  /// In en, this message translates to:
  /// **'Task 2'**
  String get onboardingLoadingStep2;

  /// No description provided for @onboardingLoadingStep3.
  ///
  /// In en, this message translates to:
  /// **'Task 3'**
  String get onboardingLoadingStep3;

  /// No description provided for @onboardingLoadingStep4.
  ///
  /// In en, this message translates to:
  /// **'Task 4'**
  String get onboardingLoadingStep4;

  /// No description provided for @onboardingLoadingStep5.
  ///
  /// In en, this message translates to:
  /// **'Task 5'**
  String get onboardingLoadingStep5;

  /// No description provided for @onboardingLoadingStep6.
  ///
  /// In en, this message translates to:
  /// **'Task 6'**
  String get onboardingLoadingStep6;

  /// No description provided for @onboardingAgeRangeQuestion.
  ///
  /// In en, this message translates to:
  /// **'What\'s your age range?'**
  String get onboardingAgeRangeQuestion;

  /// No description provided for @onboardingGenderQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do you identify?'**
  String get onboardingGenderQuestion;

  /// No description provided for @onboardingWhereHeard.
  ///
  /// In en, this message translates to:
  /// **'Where did you hear about us?'**
  String get onboardingWhereHeard;

  /// No description provided for @onboardingYouTube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get onboardingYouTube;

  /// No description provided for @onboardingFacebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get onboardingFacebook;

  /// No description provided for @onboardingTwitter.
  ///
  /// In en, this message translates to:
  /// **'X (Twitter)'**
  String get onboardingTwitter;

  /// No description provided for @onboardingReddit.
  ///
  /// In en, this message translates to:
  /// **'Reddit'**
  String get onboardingReddit;

  /// No description provided for @onboardingAppStore.
  ///
  /// In en, this message translates to:
  /// **'App Store'**
  String get onboardingAppStore;

  /// No description provided for @onboardingFriendFamily.
  ///
  /// In en, this message translates to:
  /// **'Friend or family'**
  String get onboardingFriendFamily;

  /// No description provided for @onboardingOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get onboardingOther;

  /// No description provided for @onboardingTimePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a time'**
  String get onboardingTimePickerTitle;

  /// No description provided for @onboardingTimePickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replace with your prompt.'**
  String get onboardingTimePickerSubtitle;

  /// No description provided for @onboardingDayPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Which days?'**
  String get onboardingDayPickerTitle;

  /// No description provided for @onboardingDayPickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the days that work for you.'**
  String get onboardingDayPickerSubtitle;

  /// No description provided for @onboardingSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get onboardingSignInTitle;

  /// No description provided for @onboardingSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save your progress and sync across devices.'**
  String get onboardingSignInSubtitle;

  /// No description provided for @onboardingSignInApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get onboardingSignInApple;

  /// No description provided for @onboardingSignInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get onboardingSignInGoogle;

  /// No description provided for @onboardingSignInEmail.
  ///
  /// In en, this message translates to:
  /// **'Continue with email'**
  String get onboardingSignInEmail;

  /// No description provided for @onboardingSkipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get onboardingSkipForNow;

  /// No description provided for @onboardingAccountNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found for that sign-in.'**
  String get onboardingAccountNotFound;

  /// No description provided for @onboardingGoogleFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get onboardingGoogleFailed;

  /// No description provided for @onboardingAppleFailed.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in failed. Please try again.'**
  String get onboardingAppleFailed;

  /// No description provided for @onboardingEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get onboardingEmailLabel;

  /// No description provided for @onboardingPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get onboardingPasswordLabel;

  /// No description provided for @onboardingEmailEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email and password.'**
  String get onboardingEmailEmptyError;

  /// No description provided for @onboardingEmailModalSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get onboardingEmailModalSignInTitle;

  /// No description provided for @onboardingEmailModalSignUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get onboardingEmailModalSignUpTitle;

  /// No description provided for @onboardingEmailSignInAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get onboardingEmailSignInAction;

  /// No description provided for @onboardingEmailSignUpAction.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get onboardingEmailSignUpAction;

  /// No description provided for @onboardingEmailHasAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get onboardingEmailHasAccount;

  /// No description provided for @onboardingEmailNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account yet? Sign up'**
  String get onboardingEmailNoAccount;

  /// No description provided for @onboardingPaywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Try the full app free'**
  String get onboardingPaywallTitle;

  /// No description provided for @onboardingPaywallTryFree.
  ///
  /// In en, this message translates to:
  /// **'Start free trial'**
  String get onboardingPaywallTryFree;

  /// No description provided for @onboardingPaywallNoPayment.
  ///
  /// In en, this message translates to:
  /// **'No payment due now'**
  String get onboardingPaywallNoPayment;

  /// No description provided for @onboardingPaywallNoCommitment.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime'**
  String get onboardingPaywallNoCommitment;

  /// No description provided for @onboardingPaywallPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get onboardingPaywallPrivacy;

  /// No description provided for @onboardingPaywallTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get onboardingPaywallTerms;

  /// No description provided for @onboardingPaywallRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get onboardingPaywallRestore;

  /// No description provided for @onboardingPaywallEula.
  ///
  /// In en, this message translates to:
  /// **'EULA'**
  String get onboardingPaywallEula;

  /// No description provided for @onboardingTrialTitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll remind you before billing'**
  String get onboardingTrialTitle;

  /// No description provided for @onboardingTrialNoPayment.
  ///
  /// In en, this message translates to:
  /// **'No payment due now'**
  String get onboardingTrialNoPayment;

  /// No description provided for @onboardingTrialContinueFree.
  ///
  /// In en, this message translates to:
  /// **'Continue for free'**
  String get onboardingTrialContinueFree;

  /// No description provided for @onboardingTrialPrice.
  ///
  /// In en, this message translates to:
  /// **'Then \$0.00 / month'**
  String get onboardingTrialPrice;

  /// No description provided for @onboardingReferralTitle.
  ///
  /// In en, this message translates to:
  /// **'Have a referral code?'**
  String get onboardingReferralTitle;

  /// No description provided for @onboardingReferralSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter it now to apply a perk to your account.'**
  String get onboardingReferralSubtitle;

  /// No description provided for @onboardingReferralLabel.
  ///
  /// In en, this message translates to:
  /// **'Referral code'**
  String get onboardingReferralLabel;

  /// No description provided for @onboardingReferralApplied.
  ///
  /// In en, this message translates to:
  /// **'Referral applied!'**
  String get onboardingReferralApplied;

  /// No description provided for @onboardingReferralInvalid.
  ///
  /// In en, this message translates to:
  /// **'That code isn\'t valid.'**
  String get onboardingReferralInvalid;

  /// No description provided for @onboardingReferralLimit.
  ///
  /// In en, this message translates to:
  /// **'That code has reached its usage limit.'**
  String get onboardingReferralLimit;

  /// No description provided for @onboardingRatingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loved by users'**
  String get onboardingRatingTitle;

  /// No description provided for @onboardingRatingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read what others have to say.'**
  String get onboardingRatingSubtitle;

  /// No description provided for @onboardingRatingMarc.
  ///
  /// In en, this message translates to:
  /// **'Marc'**
  String get onboardingRatingMarc;

  /// No description provided for @onboardingRatingMarcReview.
  ///
  /// In en, this message translates to:
  /// **'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'**
  String get onboardingRatingMarcReview;

  /// No description provided for @onboardingRatingSophie.
  ///
  /// In en, this message translates to:
  /// **'Sophie'**
  String get onboardingRatingSophie;

  /// No description provided for @onboardingRatingSophieReview.
  ///
  /// In en, this message translates to:
  /// **'Sed do eiusmod tempor incididunt ut labore et dolore magna.'**
  String get onboardingRatingSophieReview;

  /// No description provided for @onboardingRatingAlex.
  ///
  /// In en, this message translates to:
  /// **'Alex'**
  String get onboardingRatingAlex;

  /// No description provided for @onboardingRatingAlexReview.
  ///
  /// In en, this message translates to:
  /// **'Ut enim ad minim veniam, quis nostrud exercitation ullamco.'**
  String get onboardingRatingAlexReview;

  /// No description provided for @referralTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter referral code'**
  String get referralTitle;

  /// No description provided for @referralCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get referralCodeLabel;

  /// No description provided for @referralSubmit.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get referralSubmit;

  /// No description provided for @referralCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get referralCancel;

  /// No description provided for @referralApplied.
  ///
  /// In en, this message translates to:
  /// **'Code applied: {plan}'**
  String referralApplied(String plan);

  /// No description provided for @referralInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid code'**
  String get referralInvalid;

  /// No description provided for @referralUsageLimit.
  ///
  /// In en, this message translates to:
  /// **'Usage limit reached'**
  String get referralUsageLimit;

  /// No description provided for @referralError.
  ///
  /// In en, this message translates to:
  /// **'Could not check code. Try again.'**
  String get referralError;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// No description provided for @chatModelName.
  ///
  /// In en, this message translates to:
  /// **'Gemini'**
  String get chatModelName;

  /// No description provided for @chatHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get chatHistoryTitle;

  /// No description provided for @chatHistorySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get chatHistorySearchHint;

  /// No description provided for @chatHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get chatHistoryEmpty;

  /// No description provided for @chatHistoryEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to start a new chat.'**
  String get chatHistoryEmptyHint;

  /// No description provided for @chatGreeting.
  ///
  /// In en, this message translates to:
  /// **'How can I help you tonight?'**
  String get chatGreeting;

  /// No description provided for @chatStartChat.
  ///
  /// In en, this message translates to:
  /// **'Start chat'**
  String get chatStartChat;

  /// No description provided for @chatComposerHint.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chatComposerHint;

  /// No description provided for @chatSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSend;

  /// No description provided for @chatNewConversation.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get chatNewConversation;

  /// No description provided for @chatUntitledConversation.
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get chatUntitledConversation;

  /// No description provided for @chatVoiceListening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get chatVoiceListening;

  /// No description provided for @chatVoiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Voice input is unavailable.'**
  String get chatVoiceUnavailable;

  /// No description provided for @chatVoicePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied.'**
  String get chatVoicePermissionDenied;

  /// No description provided for @chatSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send message. Please try again.'**
  String get chatSendFailed;

  /// No description provided for @chatDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get chatDelete;

  /// No description provided for @chatDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this conversation?'**
  String get chatDeleteConfirm;

  /// No description provided for @chatDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get chatDeleteCancel;

  /// No description provided for @chatRelativeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get chatRelativeJustNow;

  /// No description provided for @chatRelativeSecondsAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} seconds ago'**
  String chatRelativeSecondsAgo(int n);

  /// No description provided for @chatRelativeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} minutes ago'**
  String chatRelativeMinutesAgo(int n);

  /// No description provided for @chatRelativeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} hours ago'**
  String chatRelativeHoursAgo(int n);

  /// No description provided for @chatRelativeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} days ago'**
  String chatRelativeDaysAgo(int n);

  /// No description provided for @chatMissionStart.
  ///
  /// In en, this message translates to:
  /// **'Start Mission'**
  String get chatMissionStart;

  /// No description provided for @chatMissionDecline.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get chatMissionDecline;

  /// No description provided for @chatMissionAccepted.
  ///
  /// In en, this message translates to:
  /// **'Mission started'**
  String get chatMissionAccepted;

  /// No description provided for @chatMissionDeclined.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get chatMissionDeclined;

  /// No description provided for @chatMissionValidated.
  ///
  /// In en, this message translates to:
  /// **'I just finished the mission!'**
  String get chatMissionValidated;

  /// No description provided for @chatMissionSetUp.
  ///
  /// In en, this message translates to:
  /// **'Set up this mission'**
  String get chatMissionSetUp;

  /// No description provided for @dismissMissionTimeToWakeUp.
  ///
  /// In en, this message translates to:
  /// **'Time to wake up!'**
  String get dismissMissionTimeToWakeUp;

  /// No description provided for @dismissMissionLabel.
  ///
  /// In en, this message translates to:
  /// **'Mission {n} of {total}: {name}'**
  String dismissMissionLabel(int n, int total, String name);

  /// No description provided for @dismissStartMission.
  ///
  /// In en, this message translates to:
  /// **'Start Mission'**
  String get dismissStartMission;

  /// No description provided for @dismissMathProgress.
  ///
  /// In en, this message translates to:
  /// **'Problem {n} of {total}'**
  String dismissMathProgress(int n, int total);

  /// No description provided for @dismissMathWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong, try again'**
  String get dismissMathWrong;

  /// No description provided for @dismissMathConfirm.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get dismissMathConfirm;

  /// No description provided for @dismissShakePrompt.
  ///
  /// In en, this message translates to:
  /// **'Shake your phone!'**
  String get dismissShakePrompt;

  /// No description provided for @dismissSpeechTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again: {score}%'**
  String dismissSpeechTryAgain(int score);

  /// No description provided for @dismissSpeechProgress.
  ///
  /// In en, this message translates to:
  /// **'Affirmation {n} of {total}'**
  String dismissSpeechProgress(int n, int total);

  /// No description provided for @dismissSpeechSay.
  ///
  /// In en, this message translates to:
  /// **'Say this aloud:'**
  String get dismissSpeechSay;

  /// No description provided for @dismissSpeechListening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get dismissSpeechListening;

  /// No description provided for @dismissSpeechTapToSpeak.
  ///
  /// In en, this message translates to:
  /// **'Tap to speak'**
  String get dismissSpeechTapToSpeak;

  /// No description provided for @dismissSpeechMicUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Microphone unavailable'**
  String get dismissSpeechMicUnavailable;

  /// No description provided for @dismissPhotoPrompt.
  ///
  /// In en, this message translates to:
  /// **'Find: {target}'**
  String dismissPhotoPrompt(String target);

  /// No description provided for @dismissPhotoNotDetected.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t detect {target}'**
  String dismissPhotoNotDetected(String target);

  /// No description provided for @dismissPhotoError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String dismissPhotoError(String error);

  /// No description provided for @dismissPhotoChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking for {target}…'**
  String dismissPhotoChecking(String target);

  /// No description provided for @dismissPhotoStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting camera…'**
  String get dismissPhotoStarting;

  /// No description provided for @dismissPhotoPickingTarget.
  ///
  /// In en, this message translates to:
  /// **'Picking your target…'**
  String get dismissPhotoPickingTarget;

  /// No description provided for @dismissFeedbackMoveIntoFrame.
  ///
  /// In en, this message translates to:
  /// **'Move into frame'**
  String get dismissFeedbackMoveIntoFrame;

  /// No description provided for @dismissFeedbackKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going!'**
  String get dismissFeedbackKeepGoing;

  /// No description provided for @dismissFeedbackPushupPosition.
  ///
  /// In en, this message translates to:
  /// **'Get in push-up position'**
  String get dismissFeedbackPushupPosition;

  /// No description provided for @dismissFeedbackStartPushups.
  ///
  /// In en, this message translates to:
  /// **'Start push-ups'**
  String get dismissFeedbackStartPushups;

  /// No description provided for @dismissFeedbackPushupGoDeeper.
  ///
  /// In en, this message translates to:
  /// **'Go deeper'**
  String get dismissFeedbackPushupGoDeeper;

  /// No description provided for @dismissFeedbackSquatPosition.
  ///
  /// In en, this message translates to:
  /// **'Keep knees over ankles'**
  String get dismissFeedbackSquatPosition;

  /// No description provided for @dismissFeedbackStartSquats.
  ///
  /// In en, this message translates to:
  /// **'Start squats'**
  String get dismissFeedbackStartSquats;

  /// No description provided for @dismissFeedbackSquatGoDeeper.
  ///
  /// In en, this message translates to:
  /// **'Squat deeper'**
  String get dismissFeedbackSquatGoDeeper;

  /// No description provided for @dismissRepStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting camera…'**
  String get dismissRepStarting;

  /// No description provided for @dismissRepPrompt.
  ///
  /// In en, this message translates to:
  /// **'Do {count} {name}'**
  String dismissRepPrompt(int count, String name);

  /// No description provided for @dismissRepOf.
  ///
  /// In en, this message translates to:
  /// **'of {target}'**
  String dismissRepOf(int target);

  /// No description provided for @missionComplete.
  ///
  /// In en, this message translates to:
  /// **'Mission Complete!'**
  String get missionComplete;

  /// No description provided for @missionCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Great job! Keep it up.'**
  String get missionCompleteMessage;

  /// No description provided for @missionPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Missions'**
  String get missionPickerTitle;

  /// No description provided for @missionPickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a mission and start now'**
  String get missionPickerSubtitle;

  /// No description provided for @breathingPhaseInhale.
  ///
  /// In en, this message translates to:
  /// **'Inhale'**
  String get breathingPhaseInhale;

  /// No description provided for @breathingPhaseHold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get breathingPhaseHold;

  /// No description provided for @breathingPhaseExhale.
  ///
  /// In en, this message translates to:
  /// **'Exhale'**
  String get breathingPhaseExhale;

  /// No description provided for @breathingRoundLabel.
  ///
  /// In en, this message translates to:
  /// **'Round {current} / {total}'**
  String breathingRoundLabel(int current, int total);

  /// No description provided for @toolSessionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get toolSessionDone;

  /// No description provided for @toolSessionLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load. Tap to retry.'**
  String get toolSessionLoadError;

  /// No description provided for @reflectionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get reflectionContinue;

  /// No description provided for @reflectionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get reflectionDone;

  /// No description provided for @reflectionSaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Please try again.'**
  String get reflectionSaveError;

  /// No description provided for @gratitudeStepPrompt.
  ///
  /// In en, this message translates to:
  /// **'What are 3 things this week that gave you joy?'**
  String get gratitudeStepPrompt;

  /// No description provided for @gratitudeHint.
  ///
  /// In en, this message translates to:
  /// **'It can be as simple as a good meal…'**
  String get gratitudeHint;

  /// No description provided for @gratitudeJoyLabel.
  ///
  /// In en, this message translates to:
  /// **'Joy {number}'**
  String gratitudeJoyLabel(int number);

  /// No description provided for @gratitudeRememberTitle.
  ///
  /// In en, this message translates to:
  /// **'Take a moment'**
  String get gratitudeRememberTitle;

  /// No description provided for @gratitudeRememberBody.
  ///
  /// In en, this message translates to:
  /// **'Remember each one, and relive the feeling it gave you.'**
  String get gratitudeRememberBody;

  /// No description provided for @gratitudeAffirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Be grateful'**
  String get gratitudeAffirmTitle;

  /// No description provided for @gratitudeAffirmBody.
  ///
  /// In en, this message translates to:
  /// **'Hold gratitude for these moments — let it settle in.'**
  String get gratitudeAffirmBody;

  /// No description provided for @selfLoveStepPrompt.
  ///
  /// In en, this message translates to:
  /// **'What are 3 things you appreciate about yourself?'**
  String get selfLoveStepPrompt;

  /// No description provided for @selfLoveHint.
  ///
  /// In en, this message translates to:
  /// **'Big or small — a strength, an effort, a kindness.'**
  String get selfLoveHint;

  /// No description provided for @selfLoveItemLabel.
  ///
  /// In en, this message translates to:
  /// **'Quality {number}'**
  String selfLoveItemLabel(int number);

  /// No description provided for @selfLoveRememberTitle.
  ///
  /// In en, this message translates to:
  /// **'Take a moment'**
  String get selfLoveRememberTitle;

  /// No description provided for @selfLoveRememberBody.
  ///
  /// In en, this message translates to:
  /// **'Read each one back to yourself, gently and without judgment.'**
  String get selfLoveRememberBody;

  /// No description provided for @selfLoveAffirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Be kind to yourself'**
  String get selfLoveAffirmTitle;

  /// No description provided for @selfLoveAffirmBody.
  ///
  /// In en, this message translates to:
  /// **'Let this kindness settle in — you deserve it.'**
  String get selfLoveAffirmBody;

  /// No description provided for @mindfulnessStepPrompt.
  ///
  /// In en, this message translates to:
  /// **'What are 3 things you notice right now?'**
  String get mindfulnessStepPrompt;

  /// No description provided for @mindfulnessHint.
  ///
  /// In en, this message translates to:
  /// **'A sound, a sensation, something you can see.'**
  String get mindfulnessHint;

  /// No description provided for @mindfulnessItemLabel.
  ///
  /// In en, this message translates to:
  /// **'Sensation {number}'**
  String mindfulnessItemLabel(int number);

  /// No description provided for @mindfulnessRememberTitle.
  ///
  /// In en, this message translates to:
  /// **'Take a moment'**
  String get mindfulnessRememberTitle;

  /// No description provided for @mindfulnessRememberBody.
  ///
  /// In en, this message translates to:
  /// **'Return to each one, and stay with it for a breath.'**
  String get mindfulnessRememberBody;

  /// No description provided for @mindfulnessAffirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Be present'**
  String get mindfulnessAffirmTitle;

  /// No description provided for @mindfulnessAffirmBody.
  ///
  /// In en, this message translates to:
  /// **'Rest here for a moment — there\'s nowhere else to be.'**
  String get mindfulnessAffirmBody;

  /// No description provided for @moodPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'How are you?'**
  String get moodPickerTitle;

  /// No description provided for @moodPickerRad.
  ///
  /// In en, this message translates to:
  /// **'rad'**
  String get moodPickerRad;

  /// No description provided for @moodPickerGood.
  ///
  /// In en, this message translates to:
  /// **'good'**
  String get moodPickerGood;

  /// No description provided for @moodPickerMeh.
  ///
  /// In en, this message translates to:
  /// **'meh'**
  String get moodPickerMeh;

  /// No description provided for @moodPickerBad.
  ///
  /// In en, this message translates to:
  /// **'bad'**
  String get moodPickerBad;

  /// No description provided for @moodPickerAwful.
  ///
  /// In en, this message translates to:
  /// **'awful'**
  String get moodPickerAwful;

  /// No description provided for @moodSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get moodSectionTitle;

  /// No description provided for @homeActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get homeActionsTitle;

  /// No description provided for @homeActionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No actions yet. Tap + to add one.'**
  String get homeActionsEmpty;

  /// No description provided for @homeHabitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get homeHabitsTitle;

  /// No description provided for @homeHabitsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No habits yet. Tap + to add one.'**
  String get homeHabitsEmpty;

  /// No description provided for @homeAddTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s next?'**
  String get homeAddTitle;

  /// No description provided for @homeAddMoodDesc.
  ///
  /// In en, this message translates to:
  /// **'Log your mood'**
  String get homeAddMoodDesc;

  /// No description provided for @homeAddMissionDesc.
  ///
  /// In en, this message translates to:
  /// **'Start a quick mission'**
  String get homeAddMissionDesc;

  /// No description provided for @homeAddBreathingTitle.
  ///
  /// In en, this message translates to:
  /// **'Breathing'**
  String get homeAddBreathingTitle;

  /// No description provided for @homeAddBreathingDesc.
  ///
  /// In en, this message translates to:
  /// **'Box breathing exercise'**
  String get homeAddBreathingDesc;

  /// No description provided for @routinePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you want to add?'**
  String get routinePickerTitle;

  /// No description provided for @routinePickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Actions are one-shot. Habits repeat.'**
  String get routinePickerSubtitle;

  /// No description provided for @routineTypeAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get routineTypeAction;

  /// No description provided for @routineTypeActionDesc.
  ///
  /// In en, this message translates to:
  /// **'A one-time task.'**
  String get routineTypeActionDesc;

  /// No description provided for @routineTypeHabit.
  ///
  /// In en, this message translates to:
  /// **'Habit'**
  String get routineTypeHabit;

  /// No description provided for @routineTypeHabitDesc.
  ///
  /// In en, this message translates to:
  /// **'Repeats on chosen days.'**
  String get routineTypeHabitDesc;

  /// No description provided for @routineFormNewAction.
  ///
  /// In en, this message translates to:
  /// **'New action'**
  String get routineFormNewAction;

  /// No description provided for @routineFormNewHabit.
  ///
  /// In en, this message translates to:
  /// **'New habit'**
  String get routineFormNewHabit;

  /// No description provided for @routineFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get routineFormEditTitle;

  /// No description provided for @routineFormCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get routineFormCreate;

  /// No description provided for @routineFormNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get routineFormNameHint;

  /// No description provided for @routineFormDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get routineFormDescriptionHint;

  /// No description provided for @routineFormColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get routineFormColorLabel;

  /// No description provided for @routineFormEmojiLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose an emoji'**
  String get routineFormEmojiLabel;

  /// No description provided for @routineFormXpLabel.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get routineFormXpLabel;

  /// No description provided for @routineFormObjectCheckLabel.
  ///
  /// In en, this message translates to:
  /// **'Object check'**
  String get routineFormObjectCheckLabel;

  /// No description provided for @routineFormObjectCheckHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. toothbrush, book, water bottle'**
  String get routineFormObjectCheckHint;

  /// No description provided for @routineFormDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get routineFormDateLabel;

  /// No description provided for @routineFormPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get routineFormPickDate;

  /// No description provided for @routineFormPickTime.
  ///
  /// In en, this message translates to:
  /// **'Pick a time'**
  String get routineFormPickTime;

  /// No description provided for @routineFormClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get routineFormClear;

  /// No description provided for @routineFormAlarmLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get routineFormAlarmLabel;

  /// No description provided for @routineFormAlarmHint.
  ///
  /// In en, this message translates to:
  /// **'Get a notification when the time arrives.'**
  String get routineFormAlarmHint;

  /// No description provided for @routineFormDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete routine?'**
  String get routineFormDeleteTitle;

  /// No description provided for @routineFormDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove it from your tracker.'**
  String get routineFormDeleteMessage;

  /// No description provided for @routineFormDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get routineFormDeleteCancel;

  /// No description provided for @routineFormDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get routineFormDeleteConfirm;

  /// No description provided for @routineCardTapToValidate.
  ///
  /// In en, this message translates to:
  /// **'Tap to validate'**
  String get routineCardTapToValidate;

  /// No description provided for @routineCardObjectCheck.
  ///
  /// In en, this message translates to:
  /// **'Photo check: {object}'**
  String routineCardObjectCheck(String object);

  /// No description provided for @routineHabitNoSchedule.
  ///
  /// In en, this message translates to:
  /// **'No schedule'**
  String get routineHabitNoSchedule;

  /// No description provided for @chatRoutineCreated.
  ///
  /// In en, this message translates to:
  /// **'Created \'{name}\''**
  String chatRoutineCreated(String name);

  /// No description provided for @chatRoutineUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated \'{name}\''**
  String chatRoutineUpdated(String name);

  /// No description provided for @chatRoutineDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted \'{name}\''**
  String chatRoutineDeleted(String name);

  /// No description provided for @chatActionStartNow.
  ///
  /// In en, this message translates to:
  /// **'Start now'**
  String get chatActionStartNow;

  /// No description provided for @chatActionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get chatActionDone;

  /// No description provided for @chatActionCompleted.
  ///
  /// In en, this message translates to:
  /// **'I just completed it!'**
  String get chatActionCompleted;

  /// No description provided for @homePageGreeting.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name} 🌿'**
  String homePageGreeting(String name);

  /// No description provided for @homePageHeadline.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing great today!'**
  String get homePageHeadline;

  /// No description provided for @homePageMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get homePageMessage;

  /// No description provided for @homePageCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get homePageCall;

  /// No description provided for @homePageCrisisMode.
  ///
  /// In en, this message translates to:
  /// **'Crisis Mode'**
  String get homePageCrisisMode;

  /// No description provided for @homePageQuestProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total}'**
  String homePageQuestProgress(int done, int total);

  /// No description provided for @homePageTodaysPlan.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Plan'**
  String get homePageTodaysPlan;

  /// No description provided for @homePageTodaysPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Small steps, big changes.'**
  String get homePageTodaysPlanSubtitle;

  /// No description provided for @homePagePlanEmpty.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set for today. Nice work!'**
  String get homePagePlanEmpty;

  /// No description provided for @defaultTaskMoodName.
  ///
  /// In en, this message translates to:
  /// **'Mood check-in'**
  String get defaultTaskMoodName;

  /// No description provided for @defaultTaskMoodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling right now?'**
  String get defaultTaskMoodSubtitle;

  /// No description provided for @defaultTaskBreathingName.
  ///
  /// In en, this message translates to:
  /// **'Breathing'**
  String get defaultTaskBreathingName;

  /// No description provided for @defaultTaskBreathingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a mindful moment'**
  String get defaultTaskBreathingSubtitle;

  /// No description provided for @defaultTaskIntrospectionName.
  ///
  /// In en, this message translates to:
  /// **'Quick introspection'**
  String get defaultTaskIntrospectionName;

  /// No description provided for @defaultTaskIntrospectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open up with Appy'**
  String get defaultTaskIntrospectionSubtitle;

  /// No description provided for @homePageEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get homePageEdit;

  /// No description provided for @homePageXp.
  ///
  /// In en, this message translates to:
  /// **'+ {xp} XP'**
  String homePageXp(int xp);

  /// No description provided for @adventureTitle.
  ///
  /// In en, this message translates to:
  /// **'Forest Adventure'**
  String get adventureTitle;

  /// No description provided for @adventureStrikeProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} strikes'**
  String adventureStrikeProgress(int done, int total);

  /// No description provided for @adventureStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start Adventure'**
  String get adventureStartButton;

  /// No description provided for @adventureDiscoverButton.
  ///
  /// In en, this message translates to:
  /// **'Discover the surprise'**
  String get adventureDiscoverButton;

  /// No description provided for @adventureRemaining.
  ///
  /// In en, this message translates to:
  /// **'Come back in {time}'**
  String adventureRemaining(String time);

  /// No description provided for @adventureSuccessLabel.
  ///
  /// In en, this message translates to:
  /// **'Trophy Earned'**
  String get adventureSuccessLabel;

  /// No description provided for @wisdomUnlockedLabel.
  ///
  /// In en, this message translates to:
  /// **'Wisdom Unlocked'**
  String get wisdomUnlockedLabel;

  /// No description provided for @trophyRevealGenerating.
  ///
  /// In en, this message translates to:
  /// **'Uncovering your wisdom…'**
  String get trophyRevealGenerating;

  /// No description provided for @trophiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Wisdom'**
  String get trophiesTitle;

  /// No description provided for @trophiesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No wisdom yet. Complete an adventure to earn your first citation.'**
  String get trophiesEmpty;

  /// No description provided for @trophyDetailDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get trophyDetailDone;

  /// No description provided for @trophyEarnedOn.
  ///
  /// In en, this message translates to:
  /// **'Earned {date}'**
  String trophyEarnedOn(String date);

  /// No description provided for @navJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get navJournal;

  /// No description provided for @navTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get navTools;

  /// No description provided for @navQuest.
  ///
  /// In en, this message translates to:
  /// **'Quest'**
  String get navQuest;

  /// No description provided for @questPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Quests'**
  String get questPageTitle;

  /// No description provided for @questPageComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Quests are coming soon.'**
  String get questPageComingSoon;

  /// No description provided for @chatPageCalmMode.
  ///
  /// In en, this message translates to:
  /// **'Calm mode'**
  String get chatPageCalmMode;

  /// No description provided for @chatPageCompanionName.
  ///
  /// In en, this message translates to:
  /// **'Appy'**
  String get chatPageCompanionName;

  /// No description provided for @chatPageCompanionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your mindful companion'**
  String get chatPageCompanionSubtitle;

  /// No description provided for @chatPageToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get chatPageToday;

  /// No description provided for @chatPageYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get chatPageYesterday;

  /// No description provided for @chatPageStartConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation'**
  String get chatPageStartConversation;

  /// No description provided for @chatPageSuggestTalkDay.
  ///
  /// In en, this message translates to:
  /// **'Talk about my day'**
  String get chatPageSuggestTalkDay;

  /// No description provided for @chatPageSuggestComfort.
  ///
  /// In en, this message translates to:
  /// **'I need comfort'**
  String get chatPageSuggestComfort;

  /// No description provided for @chatPageSuggestReflect.
  ///
  /// In en, this message translates to:
  /// **'Help me reflect'**
  String get chatPageSuggestReflect;

  /// No description provided for @chatPageComposerHint.
  ///
  /// In en, this message translates to:
  /// **'Your message'**
  String get chatPageComposerHint;

  /// No description provided for @chatInsightsFormingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your insights are forming'**
  String get chatInsightsFormingTitle;

  /// No description provided for @chatInsightsFormingBody.
  ///
  /// In en, this message translates to:
  /// **'Ash just needs a little more context from this conversation before it can reflect an insight back to you.'**
  String get chatInsightsFormingBody;

  /// No description provided for @chatInsightsReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'An insight is ready'**
  String get chatInsightsReadyTitle;

  /// No description provided for @chatInsightsReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Ash has spotted something in this conversation worth reflecting back to you.'**
  String get chatInsightsReadyBody;

  /// No description provided for @chatInsightsContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue conversation'**
  String get chatInsightsContinue;

  /// No description provided for @chatInsightsReveal.
  ///
  /// In en, this message translates to:
  /// **'Reveal insight'**
  String get chatInsightsReveal;

  /// No description provided for @chatInsightCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Insight'**
  String get chatInsightCardLabel;

  /// No description provided for @chatInsightCardCta.
  ///
  /// In en, this message translates to:
  /// **'Read insight'**
  String get chatInsightCardCta;

  /// No description provided for @journalTitle.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journalTitle;

  /// No description provided for @journalInsightsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No insights yet'**
  String get journalInsightsEmptyTitle;

  /// No description provided for @journalInsightsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your insights from chats with Appy will show up here.'**
  String get journalInsightsEmptyBody;

  /// No description provided for @journalInsightsEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Start chatting'**
  String get journalInsightsEmptyCta;

  /// No description provided for @shopComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get shopComingSoon;

  /// No description provided for @shopCtaBackground.
  ///
  /// In en, this message translates to:
  /// **'Change background'**
  String get shopCtaBackground;

  /// No description provided for @shopCtaHat.
  ///
  /// In en, this message translates to:
  /// **'Buy new hat'**
  String get shopCtaHat;

  /// No description provided for @shopCtaGlass.
  ///
  /// In en, this message translates to:
  /// **'Buy new glasses'**
  String get shopCtaGlass;

  /// No description provided for @shopCtaScarf.
  ///
  /// In en, this message translates to:
  /// **'Buy new scarf'**
  String get shopCtaScarf;

  /// No description provided for @shopCtaColor.
  ///
  /// In en, this message translates to:
  /// **'Change color'**
  String get shopCtaColor;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
