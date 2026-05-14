import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../subscription/services/analytics_service.dart';
import '../models/mood_entry.dart';
import '../services/mood_service.dart';
import 'mood_state.dart';

class MoodCubit extends Cubit<MoodState> {
  StreamSubscription<Map<int, MoodValue>>? _sub;

  MoodCubit() : super(const MoodState()) {
    _subscribe();
  }

  void _subscribe() {
    _sub?.cancel();
    _sub = MoodService.watchWeekMoods().listen(
      (weekMoods) {
        if (!isClosed) emit(state.copyWith(weekMoods: weekMoods));
      },
      onError: (e) => debugPrint('[MoodCubit] watchWeekMoods error: $e'),
    );
  }

  /// Saves [mood] to Firestore and fires the analytics event.
  Future<void> saveMood(MoodValue mood, {String source = 'modal'}) async {
    if (state.isSaving) return;
    emit(state.copyWith(isSaving: true));
    try {
      await MoodService.saveMood(mood);
      await AnalyticsService.capture(
        AnalyticsService.moodRecorded,
        {'mood': mood.name, 'source': source},
      );
      debugPrint('[MoodCubit] mood saved: ${mood.name}');
    } catch (e) {
      debugPrint('[MoodCubit] saveMood failed: $e');
    } finally {
      if (!isClosed) emit(state.copyWith(isSaving: false));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
