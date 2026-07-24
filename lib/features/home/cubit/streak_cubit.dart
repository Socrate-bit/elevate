import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../activity/models/activity.dart';
import '../../activity/services/activity_service.dart';
import '../services/heart_service.dart';
import '../services/streak_service.dart';
import 'streak_state.dart';

/// App-wide cubit driving the pet's daily engagement: the streak (distinct
/// active days on a rolling window) and hearts (health that decays with
/// inactivity). Both are derived from a single activity stream — no separate
/// persistence. A periodic tick keeps them fresh (streak break / heart decay)
/// across time while the app stays open.
class StreakCubit extends Cubit<StreakState> {
  StreakCubit() : super(const StreakState()) {
    _subscribe();
    _tick = Timer.periodic(const Duration(minutes: 5), (_) => _recompute());
  }

  StreamSubscription<List<Activity>>? _activitiesSub;
  Timer? _tick;

  List<Activity> _activities = [];
  bool _activitiesReady = false;

  void _subscribe() {
    _activitiesSub = ActivityService.watchActivities(limit: 500).listen((
      activities,
    ) {
      _activities = activities;
      _activitiesReady = true;
      _recompute();
    });
  }

  void _recompute() {
    if (isClosed) return;
    final streak = StreakService.computeStreak(_activities);
    final bestStreak = StreakService.computeBestStreak(_activities);

    // Hearts decay from the last completed activity (stream is newest-first).
    DateTime? lastActivityAt;
    for (final a in _activities) {
      if (a.completed) {
        lastActivityAt = a.timestamp;
        break;
      }
    }
    final hearts = HeartService.computeHearts(lastActivityAt);

    emit(
      state.copyWith(
        streak: streak,
        bestStreak: bestStreak,
        hearts: hearts,
        loading: !_activitiesReady,
      ),
    );
  }

  @override
  Future<void> close() {
    _activitiesSub?.cancel();
    _tick?.cancel();
    return super.close();
  }
}
