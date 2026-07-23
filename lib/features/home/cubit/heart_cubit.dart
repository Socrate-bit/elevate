import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../activity/models/activity.dart';
import '../../activity/services/activity_service.dart';
import '../../milestones/services/streak_service.dart';
import '../../routines/cubit/routine_cubit.dart';
import '../../routines/cubit/routine_state.dart';
import '../../routines/models/routine.dart';
import '../../subscription/services/analytics_service.dart';
import '../services/heart_service.dart';
import 'heart_state.dart';

/// App-wide cubit driving the pet's hearts (health) and the reactive streak.
///
/// Hearts are derived from the last completed activity's timestamp — no
/// per-heart writes. When hearts fully deplete, the streak break is persisted
/// once so it survives app restarts, and the streak is computed with that
/// break as a floor (see [StreakService.computeStreak]'s `stopDate`).
class HeartCubit extends Cubit<HeartState> {
  HeartCubit({required RoutineCubit routineCubit})
    : _routineCubit = routineCubit,
      super(const HeartState()) {
    _subscribe();
    // Time-based decay ticks even without new data while the app is open.
    _tick = Timer.periodic(const Duration(minutes: 5), (_) => _recompute());
  }

  final RoutineCubit _routineCubit;
  StreamSubscription<List<Activity>>? _activitiesSub;
  StreamSubscription<RoutineState>? _routinesSub;
  StreamSubscription<StreakProfile>? _profileSub;
  Timer? _tick;

  List<Activity> _activities = [];
  List<Routine> _routines = [];
  StreakProfile _profile = const StreakProfile();
  bool _activitiesReady = false;
  bool _routinesReady = false;
  bool _profileReady = false;

  void _subscribe() {
    _activitiesSub = ActivityService.watchActivities(limit: 500).listen((
      activities,
    ) {
      _activities = activities;
      _activitiesReady = true;
      _recompute();
    });

    _routines = _routineCubit.state.routines;
    _routinesReady = !_routineCubit.state.isLoading;
    _routinesSub = _routineCubit.stream.listen((rs) {
      _routines = rs.routines;
      _routinesReady = !rs.isLoading;
      _recompute();
    });

    _profileSub = StreakService.watchProfile().listen((profile) {
      _profile = profile;
      _profileReady = true;
      _recompute();
    });
  }

  void _recompute() {
    if (isClosed) return;
    final loading = !_activitiesReady || !_routinesReady || !_profileReady;

    // Last completed activity drives heart decay (stream is newest-first).
    DateTime? lastActivityAt;
    for (final a in _activities) {
      if (a.completed) {
        lastActivityAt = a.timestamp;
        break;
      }
    }

    final hearts = HeartService.computeHearts(lastActivityAt);

    // Persist the streak break once, when hearts have just fully depleted.
    final depletedAt = HeartService.heartsDepletedAt(lastActivityAt);
    if (hearts == 0 &&
        depletedAt != null &&
        (_profile.streakBrokenAt == null ||
            _profile.streakBrokenAt!.isBefore(depletedAt))) {
      HeartService.recordStreakBreak(depletedAt);
      AnalyticsService.capture(
        AnalyticsService.streakBroken,
        {'streak': state.streak},
      );
      // watchProfile emits the new streakBrokenAt → triggers a fresh recompute.
    }

    final streak = StreakService.computeStreak(
      activities: _activities,
      routines: _routines,
      stopDate: _profile.streakBrokenAt,
    ).streak;

    emit(state.copyWith(hearts: hearts, streak: streak, loading: loading));
  }

  @override
  Future<void> close() {
    _activitiesSub?.cancel();
    _routinesSub?.cancel();
    _profileSub?.cancel();
    _tick?.cancel();
    return super.close();
  }
}
