import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../notifications/notification_service.dart';
import '../../activity/services/activity_service.dart';
import '../models/routine.dart';
import '../services/routine_firestore_service.dart';
import 'routine_state.dart';

/// Owns the user's routines (actions + habits). CRUD against Firestore +
/// optional local reminder notifications (see [NotificationService]). When a
/// routine opts into a reminder, `nativeAlarmId` stores a marker so the
/// scheduled/cleared state survives reloads.
class RoutineCubit extends Cubit<RoutineState> {
  RoutineCubit({Uuid? uuid})
      : _uuid = uuid ?? const Uuid(),
        super(const RoutineState(isLoading: true)) {
    _subscribe();
  }

  final Uuid _uuid;
  StreamSubscription? _sub;

  void _subscribe() {
    _sub?.cancel();
    _sub = RoutineFirestoreService.watchRoutines().listen(
      (routines) =>
          emit(state.copyWith(routines: routines, isLoading: false)),
      onError: (e) {
        debugPrint('[RoutineCubit] watchRoutines error: $e');
        emit(state.copyWith(isLoading: false));
      },
    );
  }

  Future<Routine> addRoutine(Routine draft) async {
    final id = draft.id.isNotEmpty ? draft.id : _uuid.v4();
    final withId = draft.copyWith(id: id);

    final nativeId = await _scheduleNativeIfNeeded(withId);
    final toSave = nativeId != null
        ? withId.copyWith(nativeAlarmId: nativeId)
        : withId;

    emit(state.copyWith(routines: [...state.routines, toSave]));

    try {
      await RoutineFirestoreService.saveRoutine(toSave);
      return toSave;
    } catch (e) {
      debugPrint('[RoutineCubit] addRoutine save failed: $e');
      emit(state.copyWith(
        routines: state.routines.where((r) => r.id != id).toList(),
      ));
      await _cancelNativeIfNeeded(toSave);
      rethrow;
    }
  }

  Future<void> editRoutine(Routine updated) async {
    final idx = state.routines.indexWhere((r) => r.id == updated.id);
    if (idx == -1) return;
    final previous = state.routines[idx];

    await _cancelNativeIfNeeded(previous);
    final nativeId = await _scheduleNativeIfNeeded(updated);
    final toSave = updated.copyWith(
      nativeAlarmId: nativeId,
      clearNativeAlarmId: nativeId == null,
    );

    final next = List<Routine>.from(state.routines)..[idx] = toSave;
    emit(state.copyWith(routines: next));

    try {
      await RoutineFirestoreService.saveRoutine(toSave);
    } catch (e) {
      debugPrint('[RoutineCubit] editRoutine save failed: $e');
      final rollback = List<Routine>.from(state.routines)..[idx] = previous;
      emit(state.copyWith(routines: rollback));
      rethrow;
    }
  }

  Future<void> removeRoutine(String id) async {
    final previous = state.routines;
    final removed = previous.where((r) => r.id == id).toList();
    emit(state.copyWith(
      routines: previous.where((r) => r.id != id).toList(),
    ));

    try {
      await RoutineFirestoreService.deleteRoutine(id);
      for (final r in removed) {
        await _cancelNativeIfNeeded(r);
      }
    } catch (e) {
      debugPrint('[RoutineCubit] removeRoutine failed: $e');
      emit(state.copyWith(routines: previous));
      rethrow;
    }
  }

  /// Removes today's completed activity for [id], resetting its validated state.
  Future<void> unvalidate(String id) async {
    try {
      await ActivityService.deleteTodayActivity(id);
      debugPrint('[RoutineCubit] unvalidated $id');
    } catch (e) {
      debugPrint('[RoutineCubit] unvalidate failed: $e');
      rethrow;
    }
  }

  /// Marks the routine as completed for today. UI is expected to disable the
  /// card while the routine is already validated today.
  Future<void> validate(String id) async {
    final idx = state.routines.indexWhere((r) => r.id == id);
    if (idx == -1) return;
    final routine = state.routines[idx];

    try {
      final activityId = await ActivityService.createPendingActivity(
        sourceId: routine.id,
        type: routine.type == RoutineType.action ? 'action' : 'habit',
      );
      await ActivityService.completeActivity(activityId, durationSeconds: 0);
    } catch (e) {
      debugPrint('[RoutineCubit] validate activity failed: $e');
      rethrow;
    }
  }

  /// Schedules a local reminder notification for [r] when [hasAlarm] + a time
  /// are present. Requests OS notification permission on first enable. Returns
  /// a marker persisted in `nativeAlarmId` to record that a reminder is set.
  Future<String?> _scheduleNativeIfNeeded(Routine r) async {
    if (!r.hasAlarm || r.scheduledMinute == null) return null;

    await NotificationService.requestPermission();
    await NotificationService.scheduleForRoutine(r);
    return 'scheduled';
  }

  Future<void> _cancelNativeIfNeeded(Routine r) async {
    await NotificationService.cancelForRoutine(r);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
