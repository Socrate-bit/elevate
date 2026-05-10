import '../../activity/models/activity.dart';

enum InsightsRange { week, month, allTime }

class InsightsState {
  final int currentStreak;
  final int longestStreak;
  final List<bool> weekDays;
  final int badgesEarned;
  final int totalBadges;
  final String avgTime;
  final String avgDuration;
  final double consistency; // 0–100
  final InsightsRange range;
  final bool loading;
  final List<Activity> activities;
  final int totalActivities;

  const InsightsState({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.weekDays = const [false, false, false, false, false, false, false],
    this.badgesEarned = 0,
    this.totalBadges = 10,
    this.avgTime = '--:--',
    this.avgDuration = '--',
    this.consistency = 0,
    this.range = InsightsRange.week,
    this.loading = true,
    this.activities = const [],
    this.totalActivities = 0,
  });

  InsightsState copyWith({
    int? currentStreak,
    int? longestStreak,
    List<bool>? weekDays,
    int? badgesEarned,
    int? totalBadges,
    String? avgTime,
    String? avgDuration,
    double? consistency,
    InsightsRange? range,
    bool? loading,
    List<Activity>? activities,
    int? totalActivities,
  }) =>
      InsightsState(
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        weekDays: weekDays ?? this.weekDays,
        badgesEarned: badgesEarned ?? this.badgesEarned,
        totalBadges: totalBadges ?? this.totalBadges,
        avgTime: avgTime ?? this.avgTime,
        avgDuration: avgDuration ?? this.avgDuration,
        consistency: consistency ?? this.consistency,
        range: range ?? this.range,
        loading: loading ?? this.loading,
        activities: activities ?? this.activities,
        totalActivities: totalActivities ?? this.totalActivities,
      );
}
