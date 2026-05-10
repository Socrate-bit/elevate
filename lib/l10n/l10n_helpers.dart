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
