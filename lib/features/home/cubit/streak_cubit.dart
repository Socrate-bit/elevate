import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../activity/models/activity.dart';
import '../../activity/services/activity_service.dart';
import '../services/streak_service.dart';
import 'streak_state.dart';

/// App-wide cubit driving the user's daily streak (consecutive days with a
/// completed activity).
///
/// Derived from the activity stream — no separate persistence. A periodic tick
/// keeps it fresh across a day boundary while the app stays open.
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
    emit(state.copyWith(streak: streak, loading: !_activitiesReady));
  }

  @override
  Future<void> close() {
    _activitiesSub?.cancel();
    _tick?.cancel();
    return super.close();
  }
}
