// Daily-streak tuning + pure helpers.
//
// The streak counts consecutive days on which the user completed at least one
// activity. It is derived from the activity timestamps (no separate persistence)
// and stays "alive" as long as there was activity today or yesterday.

import '../../activity/models/activity.dart';

class StreakService {
  /// Consecutive-day streak ending today (or yesterday, so it doesn't break
  /// until a full day is missed). Days with no completed activity break it.
  static int computeStreak(List<Activity> activities, {DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());

    // Set of distinct days that have at least one completed activity.
    final days = <DateTime>{
      for (final a in activities)
        if (a.completed) _dateOnly(a.timestamp),
    };
    if (days.isEmpty) return 0;

    // The streak is alive from today, or from yesterday if nothing done today.
    var cursor = today;
    if (!days.contains(cursor)) {
      cursor = today.subtract(const Duration(days: 1));
      if (!days.contains(cursor)) return 0;
    }

    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
