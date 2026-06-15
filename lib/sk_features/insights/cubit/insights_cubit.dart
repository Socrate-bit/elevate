import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../activity/models/activity.dart';
import '../../activity/services/activity_service.dart';
import '../../milestones/services/streak_service.dart';
import '../../mood/services/mood_service.dart';
import 'insights_state.dart';

class InsightsCubit extends Cubit<InsightsState> {
  StreamSubscription<List<Activity>>? _activitiesSub;
  StreamSubscription<StreakProfile>? _profileSub;
  StreamSubscription<Map<DateTime, MoodValue>>? _moodSub;
  Completer<void>? _loadCompleter;

  List<Activity> _allActivities = [];
  StreakProfile _profile = const StreakProfile();
  bool _activitiesReady = false;
  bool _profileReady = false;

  InsightsCubit() : super(const InsightsState()) {
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

    _subscribeMoods();
  }

  void _subscribeMoods() {
    _moodSub?.cancel();
    final now = DateTime.now();
    final start = _moodRangeStart(now);
    _moodSub = MoodService.watchMoodsInRange(
      start,
      now.add(const Duration(days: 1)),
    ).listen(
      (moods) {
        if (!isClosed) emit(state.copyWith(moodsByDay: moods));
      },
      onError: (e) => debugPrint('[InsightsCubit] watchMoodsInRange error: $e'),
    );
  }

  DateTime _moodRangeStart(DateTime now) => switch (state.range) {
        InsightsRange.week => _startOfWeek(now),
        InsightsRange.month => DateTime(now.year, now.month, 1),
        InsightsRange.allTime => now.subtract(const Duration(days: 90)),
      };

  Future<void> load() {
    _loadCompleter?.complete();
    _loadCompleter = Completer<void>();
    emit(state.copyWith(loading: true));
    _cancelSubs();
    _subscribe();
    return _loadCompleter!.future;
  }

  Future<void> changeRange(InsightsRange range) async {
    if (state.range == range) return;
    emit(state.copyWith(range: range));
    _subscribeMoods();
    await _recompute();
  }

  Future<void> _recompute() async {
    if (isClosed) return;
    final range = state.range;
    final now = DateTime.now();

    final DateTime? since = switch (range) {
      InsightsRange.week => _startOfWeek(now),
      InsightsRange.month => DateTime(now.year, now.month, 1),
      InsightsRange.allTime => null,
    };

    final activities = since != null
        ? _allActivities.where((a) => a.timestamp.isAfter(since)).toList()
        : _allActivities;

    final startOfWeek = _startOfWeek(now);
    final weekActivities =
        _allActivities.where((a) => a.timestamp.isAfter(startOfWeek)).toList();
    final weekDays = List<bool>.filled(7, false);
    for (final a in weekActivities) {
      weekDays[a.timestamp.weekday % 7] = true;
    }

    final currentStreak =
        await StreakService.computeCurrentStreak(_allActivities);

    if (isClosed) return;

    final totalActivities = _allActivities.where((a) => a.completed).length;

    emit(state.copyWith(
      currentStreak: currentStreak,
      longestStreak: _profile.longestStreak,
      weekDays: weekDays,
      badgesEarned: _profile.earnedBadgeIds.length,
      avgTime: _computeAvgTime(activities),
      avgDuration: _computeAvgDuration(activities),
      consistency: _computeConsistency(activities, range, now),
      activities: activities,
      totalActivities: totalActivities,
      loading: false,
    ));

    _loadCompleter?.complete();
    _loadCompleter = null;
  }

  void _cancelSubs() {
    _activitiesSub?.cancel();
    _profileSub?.cancel();
    _moodSub?.cancel();
    _activitiesSub = null;
    _profileSub = null;
    _moodSub = null;
  }

  @override
  Future<void> close() {
    _cancelSubs();
    _loadCompleter?.complete();
    _loadCompleter = null;
    return super.close();
  }

  String _computeAvgTime(List<Activity> activities) {
    if (activities.isEmpty) return '--:--';
    final totalMinutes = activities
        .map((a) => a.timestamp.hour * 60 + a.timestamp.minute)
        .reduce((a, b) => a + b);
    final avgMin = totalMinutes ~/ activities.length;
    final h24 = avgMin ~/ 60;
    final m = (avgMin % 60).toString().padLeft(2, '0');
    final period = h24 < 12 ? 'AM' : 'PM';
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    return '$h12:$m $period';
  }

  String _computeAvgDuration(List<Activity> activities) {
    if (activities.isEmpty) return '--';
    final totalSec =
        activities.map((a) => a.durationSeconds).reduce((a, b) => a + b);
    final avgSec = totalSec ~/ activities.length;
    if (avgSec >= 60) {
      final m = avgSec ~/ 60;
      final s = avgSec % 60;
      return '${m}m ${s}s';
    }
    return '${avgSec}s';
  }

  double _computeConsistency(
    List<Activity> activities,
    InsightsRange range,
    DateTime now,
  ) {
    if (activities.isEmpty) return 0;

    final distinctDays = activities.map((a) {
      final t = a.timestamp;
      return '${t.year}-${t.month}-${t.day}';
    }).toSet().length;

    final int totalDays = switch (range) {
      InsightsRange.week => 7,
      InsightsRange.month => now.day,
      InsightsRange.allTime => () {
          if (activities.isEmpty) return 1;
          final oldest = activities.last.timestamp;
          return max(1, now.difference(oldest).inDays + 1);
        }(),
    };

    return min(distinctDays / totalDays * 100, 100);
  }

  DateTime _startOfWeek(DateTime date) {
    final daysFromSunday = date.weekday % 7;
    return DateTime(date.year, date.month, date.day - daysFromSunday);
  }
}
