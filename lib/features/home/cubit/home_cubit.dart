import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../activity/models/activity.dart';
import '../../activity/services/activity_service.dart';
import '../../milestones/services/streak_service.dart';
import '../../routines/cubit/routine_cubit.dart';
import '../../routines/cubit/routine_state.dart';
import '../../routines/models/routine.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required RoutineCubit routineCubit})
      : _routineCubit = routineCubit,
        super(const HomeState()) {
    _subscribe();
  }

  final RoutineCubit _routineCubit;
  StreamSubscription<List<Activity>>? _activitiesSub;
  StreamSubscription<StreakProfile>? _profileSub;
  StreamSubscription<RoutineState>? _routinesSub;
  Completer<void>? _loadCompleter;

  List<Activity> _allActivities = [];
  List<Routine> _routines = [];
  StreakProfile _profile = const StreakProfile();
  bool _activitiesReady = false;
  bool _profileReady = false;
  bool _routinesReady = false;

  void _subscribe() {
    _activitiesReady = false;
    _profileReady = false;
    _routinesReady = false;

    _activitiesSub =
        ActivityService.watchActivities(limit: 500).listen((activities) {
      _allActivities = activities;
      _activitiesReady = true;
      _recomputeIfReady();
    });

    _profileSub = StreakService.watchProfile().listen((profile) {
      _profile = profile;
      _profileReady = true;
      _recomputeIfReady();
    });

    _routines = _routineCubit.state.routines;
    _routinesReady = !_routineCubit.state.isLoading;
    _routinesSub = _routineCubit.stream.listen((rs) {
      _routines = rs.routines;
      _routinesReady = !rs.isLoading;
      _recomputeIfReady();
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

  void _recomputeIfReady() {
    if (!_activitiesReady || !_profileReady || !_routinesReady) return;
    _recompute();
  }

  void _recompute() {
    if (isClosed) return;

    final completed =
        _allActivities.where((a) => a.completed).toList();
    final lastActivity =
        completed.isEmpty ? null : completed.first;
    final result = StreakService.computeStreak(
      activities: _allActivities,
      routines: _routines,
    );

    emit(state.copyWith(
      currentStreak: result.streak,
      weekDays: result.weekDays,
      lastActivity: lastActivity,
      clearLastActivity: lastActivity == null,
      completedActivities: completed,
      totalActivities: _profile.totalActivities,
      loading: false,
    ));

    _loadCompleter?.complete();
    _loadCompleter = null;
  }

  void _cancelSubs() {
    _activitiesSub?.cancel();
    _profileSub?.cancel();
    _routinesSub?.cancel();
    _activitiesSub = null;
    _profileSub = null;
    _routinesSub = null;
  }

  @override
  Future<void> close() {
    _cancelSubs();
    _loadCompleter?.complete();
    _loadCompleter = null;
    return super.close();
  }
}
