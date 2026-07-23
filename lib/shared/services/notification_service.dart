import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/routines/models/routine.dart';

/// Local (banner) notification reminders for routines.
///
/// Reuses the routine's existing scheduling fields: a reminder is scheduled
/// only when `hasAlarm` is on and a `scheduledMinute` is set. Actions fire a
/// one-shot at `scheduledDate` + time; habits fire a weekly-repeating
/// notification per active weekday.
///
/// Notification ids are derived deterministically from the routine id so
/// scheduling and cancelling stay in sync without persisting extra state — see
/// [_slotId]. Currently iOS-only (no Android platform folder).
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// One-shot slot for actions; weekday slots (1..7) for habits.
  static const int _actionSlot = 0;

  static const _iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  static const _details = NotificationDetails(iOS: _iosDetails);

  /// Initializes the timezone database and the plugin. Call once from `main()`.
  /// Permission is requested lazily (see [requestPermission]), not here.
  static Future<void> init() async {
    try {
      tz_data.initializeTimeZones();
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz.identifier));

      await _plugin.initialize(
        settings: const InitializationSettings(
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        // Tapping a reminder just opens the app; no deep-linking.
        onDidReceiveNotificationResponse: (_) {},
      );
      debugPrint('[NotificationService] initialized (tz=${tz.local.name})');
    } catch (e) {
      debugPrint('[NotificationService] init failed: $e');
    }
  }

  /// Requests iOS notification permission. Returns whether it was granted.
  /// Called the first time a reminder is enabled.
  static Future<bool> requestPermission() async {
    try {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      if (granted != true) {
        debugPrint('[NotificationService] permission not granted');
      }
      return granted ?? false;
    } catch (e) {
      debugPrint('[NotificationService] requestPermission failed: $e');
      return false;
    }
  }

  /// Schedules the reminder(s) for [r]. Cancels any existing reminders for the
  /// same routine first, so this is safe to call on both create and edit.
  static Future<void> scheduleForRoutine(Routine r) async {
    await cancelForRoutine(r);

    if (!r.hasAlarm || r.scheduledMinute == null) return;
    final minute = r.scheduledMinute!;

    try {
      if (r.type == RoutineType.action) {
        final date = r.scheduledDate;
        if (date == null) return;
        final when = tz.TZDateTime(
          tz.local,
          date.year,
          date.month,
          date.day,
          minute ~/ 60,
          minute % 60,
        );
        // Don't schedule a one-shot in the past.
        if (!when.isAfter(tz.TZDateTime.now(tz.local))) return;
        await _plugin.zonedSchedule(
          id: _slotId(r.id, _actionSlot),
          title: _title(r),
          body: r.description,
          scheduledDate: when,
          notificationDetails: _details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        debugPrint('[NotificationService] scheduled action ${r.id} at $when');
        return;
      }

      // Habit: one weekly-repeating notification per active weekday.
      for (var i = 0; i < r.scheduledDays.length; i++) {
        if (!r.scheduledDays[i]) continue;
        final when = _nextInstanceOfWeekday(i, minute);
        await _plugin.zonedSchedule(
          id: _slotId(r.id, i + 1),
          title: _title(r),
          body: r.description,
          scheduledDate: when,
          notificationDetails: _details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
      debugPrint('[NotificationService] scheduled habit ${r.id}');
    } catch (e) {
      debugPrint('[NotificationService] scheduleForRoutine ${r.id} failed: $e');
    }
  }

  /// Cancels every reminder slot for [r] (idempotent; unknown ids are no-ops).
  static Future<void> cancelForRoutine(Routine r) async {
    try {
      for (var slot = 0; slot <= 7; slot++) {
        await _plugin.cancel(id: _slotId(r.id, slot));
      }
    } catch (e) {
      debugPrint('[NotificationService] cancelForRoutine ${r.id} failed: $e');
    }
  }

  static String? _title(Routine r) => r.name.isEmpty ? null : r.name;

  /// Next occurrence of [dayIndex] (0=Sun..6=Sat) at [minute] minutes since
  /// midnight, strictly in the future, in the local timezone.
  static tz.TZDateTime _nextInstanceOfWeekday(int dayIndex, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      minute ~/ 60,
      minute % 60,
    );
    // weekday: Mon=1..Sun=7; `% 7` maps to Sun=0..Sat=6 (matches scheduledDays).
    while (scheduled.weekday % 7 != dayIndex || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Deterministic 32-bit notification id: an 8-slot block per routine (slot 0 =
  /// action one-shot, slots 1..7 = habit weekdays). The same id is derived for
  /// schedule and cancel, so no extra state is persisted.
  static int _slotId(String routineId, int slot) =>
      (routineId.hashCode & 0x7FFFFFF8) | slot;
}
