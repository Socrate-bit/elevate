import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../activity/models/activity.dart';
import '../../activity/services/activity_service.dart';
import '../../adventure/models/game_profile.dart';
import '../../adventure/services/adventure_service.dart';
import '../services/streak_service.dart';
import 'streak_state.dart';

/// App-wide cubit driving the daily streak (distinct active days). The run is
/// bounded by [GameProfile.streakAnchorMs] — the moment hearts last hit zero —
/// so "no hearts → lose the streak" is enforced by ignoring activities before
/// that anchor. Derived from a single activity stream (no streak persistence);
/// hearts themselves live on the game profile now. A periodic tick keeps it
/// fresh across time while the app stays open.
class StreakCubit extends Cubit<StreakState> {
  StreakCubit() : super(const StreakState()) {
    _subscribe();
    _tick = Timer.periodic(const Duration(minutes: 5), (_) => _recompute());
  }

  StreamSubscription<List<Activity>>? _activitiesSub;
  StreamSubscription<GameProfile>? _profileSub;
  Timer? _tick;

  List<Activity> _activities = [];
  bool _activitiesReady = false;
  int? _streakAnchorMs;

  void _subscribe() {
    _activitiesSub = ActivityService.watchActivities(limit: 500).listen((
      activities,
    ) {
      _activities = activities;
      _activitiesReady = true;
      _recompute();
    });
    // Track the hearts-zero anchor that bounds the current run.
    _profileSub = AdventureService.watchProfile().listen((profile) {
      _streakAnchorMs = profile.streakAnchorMs;
      _recompute();
    });
  }

  void _recompute() {
    if (isClosed) return;

    // Only activities after the last hearts-zero reset count toward the run.
    final anchor = _streakAnchorMs;
    final scoped = anchor == null
        ? _activities
        : [
            for (final a in _activities)
              if (a.timestamp.millisecondsSinceEpoch > anchor) a,
          ];

    final streak = StreakService.computeStreak(scoped);
    final bestStreak = StreakService.computeBestStreak(_activities);

    emit(
      state.copyWith(
        streak: streak,
        bestStreak: bestStreak,
        loading: !_activitiesReady,
      ),
    );
  }

  @override
  Future<void> close() {
    _activitiesSub?.cancel();
    _profileSub?.cancel();
    _tick?.cancel();
    return super.close();
  }
}
