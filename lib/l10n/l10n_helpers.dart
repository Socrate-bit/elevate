import 'package:elevate/l10n/generated/app_localizations.dart';

/// Returns the localized month abbreviation (1-indexed).
String localizedMonth(AppLocalizations l10n, int month) {
  switch (month) {
    case 1:
      return l10n.monthJan;
    case 2:
      return l10n.monthFeb;
    case 3:
      return l10n.monthMar;
    case 4:
      return l10n.monthApr;
    case 5:
      return l10n.monthMay;
    case 6:
      return l10n.monthJun;
    case 7:
      return l10n.monthJul;
    case 8:
      return l10n.monthAug;
    case 9:
      return l10n.monthSep;
    case 10:
      return l10n.monthOct;
    case 11:
      return l10n.monthNov;
    case 12:
      return l10n.monthDec;
    default:
      return '';
  }
}

/// Returns the short day label (3-letter) for a weekday (0=Sun, 6=Sat).
String localizedDayShort(AppLocalizations l10n, int day) {
  switch (day) {
    case 0:
      return l10n.daySun;
    case 1:
      return l10n.dayMon;
    case 2:
      return l10n.dayTue;
    case 3:
      return l10n.dayWed;
    case 4:
      return l10n.dayThu;
    case 5:
      return l10n.dayFri;
    case 6:
      return l10n.daySat;
    default:
      return '';
  }
}

/// Returns the localized name of the streak milestone earned at [days].
String localizedStreakBadgeName(AppLocalizations l10n, int days) {
  switch (days) {
    case 1:
      return l10n.streakBadge1Name;
    case 3:
      return l10n.streakBadge3Name;
    case 7:
      return l10n.streakBadge7Name;
    case 14:
      return l10n.streakBadge14Name;
    case 30:
      return l10n.streakBadge30Name;
    case 100:
      return l10n.streakBadge100Name;
    case 365:
      return l10n.streakBadge365Name;
    default:
      return '';
  }
}

/// Returns the localized inspirational quote for the milestone at [days].
String localizedStreakBadgeQuote(AppLocalizations l10n, int days) {
  switch (days) {
    case 1:
      return l10n.streakBadge1Quote;
    case 3:
      return l10n.streakBadge3Quote;
    case 7:
      return l10n.streakBadge7Quote;
    case 14:
      return l10n.streakBadge14Quote;
    case 30:
      return l10n.streakBadge30Quote;
    case 100:
      return l10n.streakBadge100Quote;
    case 365:
      return l10n.streakBadge365Quote;
    default:
      return '';
  }
}

/// Returns the full day name for a weekday (0=Sun, 6=Sat).
String localizedDayFull(AppLocalizations l10n, int day) {
  switch (day) {
    case 0:
      return l10n.daySundayFull;
    case 1:
      return l10n.dayMondayFull;
    case 2:
      return l10n.dayTuesdayFull;
    case 3:
      return l10n.dayWednesdayFull;
    case 4:
      return l10n.dayThursdayFull;
    case 5:
      return l10n.dayFridayFull;
    case 6:
      return l10n.daySaturdayFull;
    default:
      return '';
  }
}
