import '../../activity/models/activity.dart';
import '../../milestones/services/streak_service.dart';

export '../../milestones/services/streak_service.dart' show DayStatus;

class HomeState {
  final int currentStreak;
  final List<DayStatus> weekDays; // Sun–Sat
  final Activity? lastActivity;
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
    this.totalActivities = 0,
    this.loading = true,
  });

  HomeState copyWith({
    int? currentStreak,
    List<DayStatus>? weekDays,
    Activity? lastActivity,
    bool clearLastActivity = false,
    int? totalActivities,
    bool? loading,
  }) =>
      HomeState(
        currentStreak: currentStreak ?? this.currentStreak,
        weekDays: weekDays ?? this.weekDays,
        lastActivity:
            clearLastActivity ? null : lastActivity ?? this.lastActivity,
        totalActivities: totalActivities ?? this.totalActivities,
        loading: loading ?? this.loading,
      );
}
