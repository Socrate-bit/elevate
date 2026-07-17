import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../activity/models/activity.dart';
import '../../activity/services/activity_service.dart';
import '../../routines/cubit/routine_cubit.dart';
import '../../routines/cubit/routine_state.dart';
import '../../routines/models/routine.dart';
import 'home_page_state.dart';

/// Drives the "Today's Plan" on the illustrated home page. Watches the real
/// routines ([RoutineCubit]) and today's completions ([ActivityService]) and
/// exposes the routines relevant today plus which are done.
class HomePageCubit extends Cubit<HomePageState> {
  HomePageCubit({required RoutineCubit routineCubit})
    : _routineCubit = routineCubit,
      super(const HomePageState()) {
    _subscribe();
  }

  final RoutineCubit _routineCubit;
  StreamSubscription<List<Activity>>? _activitiesSub;
  StreamSubscription<RoutineState>? _routinesSub;

  List<Activity> _activities = [];
  List<Routine> _routines = [];
  bool _activitiesReady = false;
  bool _routinesReady = false;

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

    _recompute();
  }

  void _recompute() {
    if (isClosed) return;
    final loading = !_activitiesReady || !_routinesReady;

    final today = DateTime.now();
    final completedTodayIds = _activities
        .where((a) => a.completed && _isSameDay(a.timestamp, today))
        .map((a) => a.sourceId)
        .whereType<String>()
        .toSet();

    // Today's plan: habits scheduled today + actions due today or undated.
    final todayRoutines =
        _routines.where((r) {
          if (r.type == RoutineType.habit) return r.isScheduledToday;
          return r.scheduledDate == null || _isSameDay(r.scheduledDate!, today);
        }).toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    emit(
      state.copyWith(
        todayRoutines: todayRoutines,
        completedTodayIds: completedTodayIds,
        loading: loading,
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Future<void> close() {
    _activitiesSub?.cancel();
    _routinesSub?.cancel();
    return super.close();
  }
}
