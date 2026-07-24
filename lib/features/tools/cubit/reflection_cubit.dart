import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../subscription/services/analytics_service.dart';
import '../models/reflection_entry.dart';
import '../models/reflection_spec.dart';
import '../services/reflection_firestore_service.dart';
import 'reflection_state.dart';

/// Drives a guided reflection session (gratitude, self-love, mindfulness…):
/// step navigation, the three items, and persisting the finished entry to the
/// Firestore collection named by [spec].
class ReflectionCubit extends Cubit<ReflectionState> {
  ReflectionCubit(this.spec, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid(),
        _service = ReflectionFirestoreService(spec.collection),
        super(const ReflectionState()) {
    AnalyticsService.capture(
      AnalyticsService.toolSessionStarted,
      {'tool': spec.analyticsName},
    );
  }

  final ReflectionSpec spec;
  final Uuid _uuid;
  final ReflectionFirestoreService _service;

  /// Updates the item at [index] (0..2) as the user types.
  void setItem(int index, String text) {
    if (index < 0 || index >= state.items.length) return;
    final next = List<String>.from(state.items)..[index] = text;
    emit(state.copyWith(items: next));
  }

  void next() => emit(state.copyWith(step: state.step + 1));

  /// Persists the entry. Returns true on success so the UI can pop; on failure
  /// logs and returns false so the UI can surface an error.
  Future<bool> save() async {
    if (state.isSaving) return false;
    emit(state.copyWith(isSaving: true));

    final entry = ReflectionEntry(
      id: _uuid.v4(),
      items: state.items.map((i) => i.trim()).toList(),
      createdAt: DateTime.now(),
    );

    try {
      await _service.saveEntry(entry);
      AnalyticsService.capture(
        AnalyticsService.toolSessionCompleted,
        {'tool': spec.analyticsName},
      );
      emit(state.copyWith(isSaving: false, saved: true));
      debugPrint('[ReflectionCubit] saved ${spec.collection} entry ${entry.id}');
      return true;
    } catch (e) {
      debugPrint('[ReflectionCubit] save failed: $e');
      emit(state.copyWith(isSaving: false));
      return false;
    }
  }
}
