// Daily-streak tuning + pure helpers.
//
// The streak rewards regular activity but tolerates the occasional missed day.
// It runs on a rolling window tied to the heart mechanic: the pet loses one
// heart every `kHeartDecayInterval` and the streak breaks once the last heart
// is gone (`kHeartMax * kHeartDecayInterval` = 48h of inactivity). A single
// missed day "freezes" the streak — the number holds (that day isn't counted)
// but the run doesn't break. It is derived from activity timestamps only (no
// separate persistence).

import '../../activity/models/activity.dart';
import 'heart_service.dart';

class StreakService {
  /// The streak breaks once this much time passes with no completed activity.
  /// Tied to hearts: it ends exactly when the pet loses its last heart.
  static final Duration _breakAfter = kHeartDecayInterval * kHeartMax;

  /// Rolling-window streak, in distinct active days.
  ///
  /// Counts the distinct calendar days with a completed activity in the current
  /// run, walking back while consecutive activity is never `_breakAfter` apart.
  /// A single missed day leaves a gap below the window, so it's silently frozen
  /// (not counted, doesn't break); two silent days exceed the window and break
  /// the run. The streak is `0` once nothing has been completed within the
  /// window.
  static int computeStreak(List<Activity> activities, {DateTime? now}) {
    final current = now ?? DateTime.now();

    // Completed-activity timestamps, newest first.
    final times = <DateTime>[
      for (final a in activities)
        if (a.completed) a.timestamp,
    ]..sort((a, b) => b.compareTo(a));
    if (times.isEmpty) return 0;

    // Broken: no completed activity within the rolling window.
    if (current.difference(times.first) >= _breakAfter) return 0;

    // Walk the run newest→oldest, collecting distinct calendar days. Missed
    // days simply don't appear (freeze); a gap >= window ends the run.
    final days = <DateTime>{_dateOnly(times.first)};
    var prev = times.first;
    for (final t in times.skip(1)) {
      if (prev.difference(t) >= _breakAfter) break;
      days.add(_dateOnly(t));
      prev = t;
    }
    return days.length;
  }

  /// Longest historical streak, in distinct active days.
  ///
  /// Walks every completed activity, splitting the timeline into runs wherever
  /// two consecutive activities are `_breakAfter` or more apart (the same
  /// break rule as [computeStreak]), and returns the largest distinct-day count
  /// across all runs. Unlike [computeStreak] there is no "now" cutoff — a past
  /// run counts even if the current streak has since broken.
  static int computeBestStreak(List<Activity> activities) {
    // Completed-activity timestamps, newest first.
    final times = <DateTime>[
      for (final a in activities)
        if (a.completed) a.timestamp,
    ]..sort((a, b) => b.compareTo(a));
    if (times.isEmpty) return 0;

    var best = 0;
    var days = <DateTime>{};
    DateTime? prev;
    for (final t in times) {
      // A gap at or beyond the window closes the current run.
      if (prev != null && prev.difference(t) >= _breakAfter) {
        if (days.length > best) best = days.length;
        days = <DateTime>{};
      }
      days.add(_dateOnly(t));
      prev = t;
    }
    if (days.length > best) best = days.length;
    return best;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
