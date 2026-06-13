import '../../activity/models/activity.dart';
import '../../milestones/services/streak_service.dart';

export '../../milestones/services/streak_service.dart' show DayStatus;

class HomeState {
  final int currentStreak;
  final List<DayStatus> weekDays; // Sun–Sat
  final Activity? lastActivity;

  /// Recent completed activities, newest-first. Used by the home view to
  /// mark which routines have been validated today.
  final List<Activity> completedActivities;
  final int totalActivities;
  final bool loading;

  const HomeState({
    this.currentStreak = 0,
    this.weekDays = const [
      DayStatus.none,
      DayStatus.none,
      DayStatus.none,
      DayStatus.none,
      DayStatus.none,
      DayStatus.none,
      DayStatus.none,
    ],
    this.lastActivity,
    this.completedActivities = const [],
    this.totalActivities = 0,
    this.loading = true,
  });

  HomeState copyWith({
    int? currentStreak,
    List<DayStatus>? weekDays,
    Activity? lastActivity,
    bool clearLastActivity = false,
    List<Activity>? completedActivities,
    int? totalActivities,
    bool? loading,
  }) => HomeState(
    currentStreak: currentStreak ?? this.currentStreak,
    weekDays: weekDays ?? this.weekDays,
    lastActivity: clearLastActivity ? null : lastActivity ?? this.lastActivity,
    completedActivities: completedActivities ?? this.completedActivities,
    totalActivities: totalActivities ?? this.totalActivities,
    loading: loading ?? this.loading,
  );
}
