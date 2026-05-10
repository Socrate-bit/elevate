import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../activity/models/activity.dart';
import '../../activity/services/activity_service.dart';
import '../../milestones/services/streak_service.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  StreamSubscription<List<Activity>>? _activitiesSub;
  StreamSubscription<StreakProfile>? _profileSub;
  Completer<void>? _loadCompleter;

  List<Activity> _allActivities = [];
  StreakProfile _profile = const StreakProfile();
  bool _activitiesReady = false;
  bool _profileReady = false;

  HomeCubit() : super(const HomeState()) {
    _subscribe();
  }

  void _subscribe() {
    _activitiesReady = false;
    _profileReady = false;

    _activitiesSub =
        ActivityService.watchActivities(limit: 500).listen((activities) {
      _allActivities = activities;
      _activitiesReady = true;
      if (_profileReady) _recompute();
    });

    _profileSub = StreakService.watchProfile().listen((profile) {
      _profile = profile;
      _profileReady = true;
      if (_activitiesReady) _recompute();
    });
  }

  Future<void> load() {
    _loadCompleter?.complete();
    _loadCompleter = Completer<void>();
    emit(state.copyWith(loading: true));
    _cancelSubs();
    _subscribe();
    return _loadCompleter!.future;
  }

  void _recompute() {
    if (isClosed) return;

    final lastActivity = _allActivities.isEmpty ? null : _allActivities.first;
    final result = StreakService.computeStreak(activities: _allActivities);

    emit(state.copyWith(
      currentStreak: result.streak,
      weekDays: result.weekDays,
      lastActivity: lastActivity,
      clearLastActivity: lastActivity == null,
      totalActivities: _profile.totalActivities,
      loading: false,
    ));

    _loadCompleter?.complete();
    _loadCompleter = null;
  }

  void _cancelSubs() {
    _activitiesSub?.cancel();
    _profileSub?.cancel();
    _activitiesSub = null;
    _profileSub = null;
  }

  @override
  Future<void> close() {
    _cancelSubs();
    _loadCompleter?.complete();
    _loadCompleter = null;
    return super.close();
  }
}
