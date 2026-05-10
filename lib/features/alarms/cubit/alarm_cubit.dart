import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../subscription/services/analytics_service.dart';
import '../../activity/services/activity_service.dart';
import '../services/alarm_channel.dart';
import '../services/alarm_firestore_service.dart';
import 'alarm_state.dart';

class AlarmCubit extends Cubit<AlarmState> {
  AlarmCubit() : super(const AlarmState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      await AlarmChannel.requestAuthorization();
    } catch (e) {
      debugPrint('[AlarmCubit] requestAuthorization failed: $e');
    }
  }

  /// Loads alarms from Firestore into state. Called on auth so the UI has
  /// data before the gated [sync] runs.
  Future<void> loadAlarm() async {
    try {
      final alarms = await AlarmFirestoreService.getAlarms();
      emit(state.copyWith(alarms: alarms));
    } catch (e) {
      debugPrint('[AlarmCubit] loadAlarm failed: $e');
    }
  }

  /// Restores alarms from Firestore (source of truth), reschedules missing
  /// native alarms, and cancels orphans.
  Future<void> sync() async {
    if (state.isLoading) return;
    emit(state.copyWith(isLoading: true));
    try {
      await _reconcileWithNative();
      await _markMissedAlarms();
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _reconcileWithNative() async {
    final results = await Future.wait([
      AlarmFirestoreService.getAlarms(),
      AlarmChannel.getAlarmIds(),
    ]);
    final firestoreAlarms = results[0] as List<AppAlarmEntry>;
    final nativeIds = (results[1] as List<String>).toSet();
    final now = DateTime.now();
    final resolved = <AppAlarmEntry>[];

    for (final alarm in firestoreAlarms) {
      if (!alarm.isEnabled) {
        if (nativeIds.contains(alarm.id)) {
          try {
            await AlarmChannel.cancel(alarm.id);
            await AlarmChannel.cleanupConfig(alarm.id);
          } catch (e) {
            debugPrint('[AlarmCubit] disabled-cleanup failed for ${alarm.id}: $e');
          }
        }
        resolved.add(alarm);
        continue;
      }

      if (nativeIds.contains(alarm.id)) {
        resolved.add(alarm);
        continue;
      }

      final isRecurrent = !alarm.isOneTime && alarm.repeatDays.any((d) => d);
      final isPast = alarm.dateTime.isBefore(now);

      if (isPast && !isRecurrent) continue;

      try {
        try {
          await AlarmChannel.cleanupConfig(alarm.id);
        } catch (_) {}
        final newId = await _scheduleNative(alarm);
        await AlarmFirestoreService.deleteAlarm(alarm.id);
        final rescheduled = alarm.copyWith(id: newId);
        await AlarmFirestoreService.saveAlarm(rescheduled);
        resolved.add(rescheduled);
      } catch (e) {
        debugPrint('[AlarmCubit] sync reschedule failed for ${alarm.id}: $e');
        resolved.add(alarm);
      }
    }

    final resolvedIds = resolved.map((a) => a.id).toSet();
    for (final nativeId in nativeIds) {
      if (resolvedIds.contains(nativeId)) continue;
      try {
        await AlarmChannel.cancel(nativeId);
        await AlarmChannel.cleanupConfig(nativeId);
      } catch (e) {
        debugPrint('[AlarmCubit] orphan cleanup failed for $nativeId: $e');
      }
    }

    for (final alarm in resolved) {
      if (!alarm.isEnabled) continue;
      if (alarm.isOneTime) continue;
      if (!alarm.repeatDays.any((d) => d)) continue;
      try {
        await AlarmChannel.primeCascadeIfNeeded(alarm.id);
      } catch (e) {
        debugPrint('[AlarmCubit] primeCascadeIfNeeded failed for ${alarm.id}: $e');
      }
    }

    emit(state.copyWith(alarms: resolved));
  }

  /// Cancels every cascade and clears the in-memory list.
  /// Used on logout — does not touch Firestore (data stays scoped to that uid).
  Future<void> cancelAllNative() async {
    try {
      final nativeIds = await AlarmChannel.getAlarmIds();
      for (final id in nativeIds) {
        try {
          await AlarmChannel.cancel(id);
          await AlarmChannel.cleanupConfig(id);
        } catch (e) {
          debugPrint('[AlarmCubit] cancelAllNative failed for $id: $e');
        }
      }
    } catch (e) {
      debugPrint('[AlarmCubit] cancelAllNative getAlarmIds failed: $e');
    }
    emit(state.copyWith(alarms: const []));
  }

  /// Creates missed activity records for enabled alarms that should have fired
  /// but have no activity record in Firestore.
  Future<void> _markMissedAlarms() async {
    try {
      final now = DateTime.now();
      final alarms = state.alarms;
      final sevenDaysAgo = DateTime(now.year, now.month, now.day - 7);

      final recent = await ActivityService.getActivities(
        limit: 500,
        since: sevenDaysAgo,
        includeIncomplete: true,
      );

      for (final alarm in alarms) {
        if (!alarm.isEnabled) continue;

        final lookbackStart = alarm.createdAt.isAfter(sevenDaysAgo)
            ? DateTime(
                alarm.createdAt.year,
                alarm.createdAt.month,
                alarm.createdAt.day,
              )
            : sevenDaysAgo;

        if (alarm.isOneTime) {
          if (!alarm.dateTime.isBefore(now)) continue;
          if (alarm.dateTime.isBefore(lookbackStart)) continue;
          final hasRecord = recent.any((a) => a.sourceId == alarm.id);
          if (!hasRecord) {
            await ActivityService.createMissedActivity(
              sourceId: alarm.id,
              type: 'alarm',
              timestamp: alarm.dateTime,
            );
          }
          continue;
        }

        final isRecurrent = alarm.repeatDays.any((d) => d);
        if (!isRecurrent) continue;

        final hour = alarm.dateTime.hour;
        final minute = alarm.dateTime.minute;

        for (
          var day = lookbackStart;
          day.isBefore(now);
          day = day.add(const Duration(days: 1))
        ) {
          final repeatIndex = day.weekday == 7 ? 0 : day.weekday;
          if (!alarm.repeatDays[repeatIndex]) continue;

          final expectedFire = DateTime(
            day.year,
            day.month,
            day.day,
            hour,
            minute,
          );
          if (!expectedFire.isBefore(now)) continue;

          final dayStart = DateTime(day.year, day.month, day.day);
          final dayEnd = dayStart.add(const Duration(days: 1));
          final hasRecord = recent.any(
            (a) =>
                a.sourceId == alarm.id &&
                a.timestamp.isAfter(dayStart) &&
                a.timestamp.isBefore(dayEnd),
          );
          if (hasRecord) continue;

          await ActivityService.createMissedActivity(
            sourceId: alarm.id,
            type: 'alarm',
            timestamp: expectedFire,
          );
        }
      }
    } catch (e) {
      debugPrint('[AlarmCubit] _markMissedAlarms failed: $e');
    }
  }

  DateTime _nextFutureDay(DateTime dt) {
    final now = DateTime.now();
    if (!dt.isBefore(now)) return dt;
    return dt.add(Duration(days: now.difference(dt).inDays + 1));
  }

  Future<void> addAlarm(AppAlarmEntry entry) async {
    final toSchedule = entry.copyWith(
      dateTime: _nextFutureDay(entry.dateTime),
    );

    final id = await _scheduleNative(toSchedule);
    final saved = toSchedule.copyWith(id: id);

    emit(state.copyWith(alarms: [...state.alarms, saved]));

    try {
      await AlarmFirestoreService.saveAlarm(saved);
    } catch (e) {
      emit(
        state.copyWith(alarms: state.alarms.where((a) => a.id != id).toList()),
      );
      await AlarmChannel.cancel(id);
      rethrow;
    }

    AnalyticsService.capture(AnalyticsService.alarmCreated, {
      'is_one_time': saved.isOneTime,
      'repeats': saved.repeatDays.where((d) => d).length,
    });
  }

  Future<void> toggleAlarm(String id, bool enabled) async {
    final alarm = state.alarms.firstWhere((a) => a.id == id);
    final previousAlarms = state.alarms;

    if (!enabled) {
      final disabledAlarm = alarm.copyWith(isEnabled: false);

      emit(
        state.copyWith(
          alarms: state.alarms
              .map((a) => a.id == id ? disabledAlarm : a)
              .toList(),
        ),
      );

      try {
        await AlarmFirestoreService.saveAlarm(disabledAlarm);
      } catch (e) {
        emit(state.copyWith(alarms: previousAlarms));
        rethrow;
      }
      try {
        await AlarmChannel.cancel(id);
      } catch (e, stack) {
        debugPrint('[AlarmCubit] Failed to cancel alarm $id: $e\n$stack');
      }
    } else {
      final now = DateTime.now();
      final toSchedule = alarm.copyWith(
        dateTime: _nextFutureDay(alarm.dateTime),
        isEnabled: true,
        createdAt: now,
      );
      final newId = await _scheduleNative(toSchedule);
      final rescheduled = toSchedule.copyWith(
        id: newId,
        disabledBySubscription: false,
      );

      emit(
        state.copyWith(
          alarms: state.alarms
              .map((a) => a.id == id ? rescheduled : a)
              .toList(),
        ),
      );

      try {
        await AlarmFirestoreService.deleteAlarm(id);
        await AlarmFirestoreService.saveAlarm(rescheduled);
      } catch (e) {
        await AlarmChannel.cancel(newId);
        emit(state.copyWith(alarms: previousAlarms));
        rethrow;
      }
    }

    AnalyticsService.capture(AnalyticsService.alarmToggled, {
      'enabled': enabled,
    });
  }

  Future<void> editAlarm(AppAlarmEntry old, AppAlarmEntry updated) async {
    final previousAlarms = state.alarms;

    await AlarmChannel.cancel(old.id);
    await AlarmChannel.cleanupConfig(old.id);

    final toSchedule = updated.copyWith(
      dateTime: _nextFutureDay(updated.dateTime),
    );

    final newId = await _scheduleNative(toSchedule);
    final saved = toSchedule.copyWith(id: newId);

    emit(
      state.copyWith(
        alarms: state.alarms.map((a) => a.id == old.id ? saved : a).toList(),
      ),
    );

    try {
      await AlarmFirestoreService.deleteAlarm(old.id);
      await AlarmFirestoreService.saveAlarm(saved);
    } catch (e) {
      await AlarmChannel.cancel(newId);
      try {
        await _scheduleNative(old);
      } catch (_) {}
      emit(state.copyWith(alarms: previousAlarms));
      rethrow;
    }

    AnalyticsService.capture(AnalyticsService.alarmUpdated);
  }

  Future<void> removeAlarm(String id) async {
    final previousAlarms = state.alarms;

    emit(
      state.copyWith(alarms: state.alarms.where((a) => a.id != id).toList()),
    );

    try {
      await AlarmFirestoreService.deleteAlarm(id);
    } catch (e) {
      debugPrint('Error deleting alarm with id $id: $e');
      emit(state.copyWith(alarms: previousAlarms));
      return;
    }

    try {
      await AlarmChannel.cancel(id);
      await AlarmChannel.cleanupConfig(id);
    } catch (e) {
      debugPrint('Error cancelling/cleaning up alarm with id $id: $e');
    }

    AnalyticsService.capture(AnalyticsService.alarmDeleted, {'alarm_id': id});
  }

  /// Schedules a native alarm, choosing one-shot or recurrent based on the
  /// entry's [repeatDays] and [isOneTime]. Uses entry.dateTime directly.
  Future<String> _scheduleNative(AppAlarmEntry entry) async {
    final title = entry.name.isNotEmpty ? entry.name : 'Alarm';
    const sfSymbol = 'alarm';
    const secondaryLabel = 'Alarm';

    final isRecurrent = !entry.isOneTime && entry.repeatDays.any((d) => d);

    if (isRecurrent) {
      return AlarmChannel.scheduleRepeating(
        weekdayMask: AlarmChannel.toWeekdayMask(entry.repeatDays),
        hour: entry.dateTime.hour,
        minute: entry.dateTime.minute,
        title: title,
        sfSymbol: sfSymbol,
        secondaryLabel: secondaryLabel,
        soundPath: null,
      );
    } else {
      return AlarmChannel.scheduleOneShot(
        timestampMs: entry.dateTime.millisecondsSinceEpoch,
        title: title,
        sfSymbol: sfSymbol,
        secondaryLabel: secondaryLabel,
        soundPath: null,
      );
    }
  }

  /// Disables all enabled alarms because the user lost their subscription.
  Future<void> disableAllForSubscription() async {
    final enabledAlarms = state.alarms.where((a) => a.isEnabled).toList();
    if (enabledAlarms.isEmpty) return;

    final updated = state.alarms.map((a) {
      if (!a.isEnabled) return a;
      return a.copyWith(isEnabled: false, disabledBySubscription: true);
    }).toList();
    emit(state.copyWith(alarms: updated));

    for (final alarm in enabledAlarms) {
      final disabled = alarm.copyWith(
        isEnabled: false,
        disabledBySubscription: true,
      );
      try {
        await AlarmFirestoreService.saveAlarm(disabled);
      } catch (e) {
        debugPrint('[AlarmCubit] disableAllForSubscription save failed ${alarm.id}: $e');
      }
      try {
        await AlarmChannel.cancel(alarm.id);
      } catch (e) {
        debugPrint('[AlarmCubit] disableAllForSubscription cancel failed ${alarm.id}: $e');
      }
    }
  }

  /// Re-enables alarms that were auto-disabled by a subscription lapse.
  Future<void> restoreSubscriptionDisabled() async {
    final toRestore = state.alarms
        .where((a) => a.disabledBySubscription)
        .toList();
    if (toRestore.isEmpty) return;

    final updatedAlarms = List<AppAlarmEntry>.from(state.alarms);

    for (final alarm in toRestore) {
      try {
        final toSchedule = alarm.copyWith(
          dateTime: _nextFutureDay(alarm.dateTime),
          isEnabled: true,
          disabledBySubscription: false,
          createdAt: DateTime.now(),
        );
        final newId = await _scheduleNative(toSchedule);
        final rescheduled = toSchedule.copyWith(id: newId);

        final idx = updatedAlarms.indexWhere((a) => a.id == alarm.id);
        if (idx != -1) updatedAlarms[idx] = rescheduled;

        await AlarmFirestoreService.deleteAlarm(alarm.id);
        await AlarmFirestoreService.saveAlarm(rescheduled);
      } catch (e) {
        debugPrint('[AlarmCubit] restoreSubscriptionDisabled failed ${alarm.id}: $e');
      }
    }

    emit(state.copyWith(alarms: updatedAlarms));
  }
}
