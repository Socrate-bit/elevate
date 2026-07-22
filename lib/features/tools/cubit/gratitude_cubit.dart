import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../subscription/services/analytics_service.dart';
import '../models/gratitude_entry.dart';
import '../services/gratitude_firestore_service.dart';
import 'gratitude_state.dart';

/// Drives the guided gratitude session: step navigation, the three joys, and
/// persisting the finished entry to Firestore.
class GratitudeCubit extends Cubit<GratitudeState> {
  GratitudeCubit({Uuid? uuid})
      : _uuid = uuid ?? const Uuid(),
        super(const GratitudeState()) {
    AnalyticsService.capture(
      AnalyticsService.toolSessionStarted,
      {'tool': _toolName},
    );
  }

  /// Tool identifier reported in the shared tool analytics funnel.
  static const _toolName = 'Gratitude';

  final Uuid _uuid;

  /// Updates the joy at [index] (0..2) as the user types.
  void setJoy(int index, String text) {
    if (index < 0 || index >= state.joys.length) return;
    final next = List<String>.from(state.joys)..[index] = text;
    emit(state.copyWith(joys: next));
  }

  void next() => emit(state.copyWith(step: state.step + 1));

  void back() {
    if (state.step > 0) emit(state.copyWith(step: state.step - 1));
  }

  /// Persists the entry. Returns true on success so the UI can pop; on failure
  /// logs and returns false so the UI can surface an error.
  Future<bool> save() async {
    if (state.isSaving) return false;
    emit(state.copyWith(isSaving: true));

    final entry = GratitudeEntry(
      id: _uuid.v4(),
      joys: state.joys.map((j) => j.trim()).toList(),
      createdAt: DateTime.now(),
    );

    try {
      await GratitudeFirestoreService.saveEntry(entry);
      AnalyticsService.capture(
        AnalyticsService.toolSessionCompleted,
        {'tool': _toolName},
      );
      emit(state.copyWith(isSaving: false, saved: true));
      debugPrint('[GratitudeCubit] saved entry ${entry.id}');
      return true;
    } catch (e) {
      debugPrint('[GratitudeCubit] save failed: $e');
      emit(state.copyWith(isSaving: false));
      return false;
    }
  }
}
