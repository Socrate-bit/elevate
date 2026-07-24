import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../activity/models/activity.dart';
import '../../activity/services/activity_service.dart';
import '../services/heart_service.dart';
import 'heart_state.dart';

/// App-wide cubit driving the pet's hearts (health).
///
/// Hearts are derived from the last completed activity's timestamp — no
/// per-heart writes. Decay is time-based, so a periodic tick keeps the value
/// fresh even without new data while the app is open.
class HeartCubit extends Cubit<HeartState> {
  HeartCubit() : super(const HeartState()) {
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
    final loading = !_activitiesReady;

    // Last completed activity drives heart decay (stream is newest-first).
    DateTime? lastActivityAt;
    for (final a in _activities) {
      if (a.completed) {
        lastActivityAt = a.timestamp;
        break;
      }
    }

    final hearts = HeartService.computeHearts(lastActivityAt);
    emit(state.copyWith(hearts: hearts, loading: loading));
  }

  @override
  Future<void> close() {
    _activitiesSub?.cancel();
    _tick?.cancel();
    return super.close();
  }
}
