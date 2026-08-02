import 'package:flutter/foundation.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../activity/services/activity_service.dart';
import '../../adventure/cubit/adventure_cubit.dart';

/// The built-in "default" daily tasks shown at the top of "Today's Plan".
enum DefaultTaskKind { mood, breathing, introspection }

/// A built-in daily prompt. Unlike a [Routine], these are not stored as
/// documents — they are always present and are marked done for the day by
/// completing their underlying feature (mood recorded, breathing finished, a
/// first chat message sent). Completion is tracked, like routines, via a
/// day-scoped `Activity` whose `sourceId` is [id]; when done today the home
/// plan hides it, and it reappears the next day.
class DefaultTask {
  /// Stable id, used as the completion activity's `sourceId`.
  final String id;
  final DefaultTaskKind kind;
  final String emoji;

  /// Key into `routine_palette.dart` (`routineColor`).
  final String colorKey;

  /// Points awarded on completion (coins + strike), mirroring routines.
  final int xp;

  const DefaultTask({
    required this.id,
    required this.kind,
    required this.emoji,
    required this.colorKey,
    required this.xp,
  });
}

const DefaultTask kMoodTask = DefaultTask(
  id: 'default_task_mood',
  kind: DefaultTaskKind.mood,
  emoji: '☀️',
  colorKey: 'yellow',
  xp: 10,
);

const DefaultTask kBreathingTask = DefaultTask(
  id: 'default_task_breathing',
  kind: DefaultTaskKind.breathing,
  emoji: '🧘',
  colorKey: 'blue',
  xp: 10,
);

const DefaultTask kIntrospectionTask = DefaultTask(
  id: 'default_task_introspection',
  kind: DefaultTaskKind.introspection,
  emoji: '🌳',
  colorKey: 'purple',
  xp: 10,
);

/// The default tasks, in display order. Breathing was removed from the daily
/// routine (to nudge introspection) — [kBreathingTask] and its screens are kept
/// but no longer surfaced here, so the routine grows exactly 20 leaves.
const List<DefaultTask> kDefaultTasks = [
  kMoodTask,
  kIntrospectionTask,
];

/// Localized card title for a default task.
String defaultTaskName(AppLocalizations l10n, DefaultTaskKind kind) =>
    switch (kind) {
      DefaultTaskKind.mood => l10n.defaultTaskMoodName,
      DefaultTaskKind.breathing => l10n.defaultTaskBreathingName,
      DefaultTaskKind.introspection => l10n.defaultTaskIntrospectionName,
    };

/// Localized card subtitle for a default task.
String defaultTaskSubtitle(AppLocalizations l10n, DefaultTaskKind kind) =>
    switch (kind) {
      DefaultTaskKind.mood => l10n.defaultTaskMoodSubtitle,
      DefaultTaskKind.breathing => l10n.defaultTaskBreathingSubtitle,
      DefaultTaskKind.introspection => l10n.defaultTaskIntrospectionSubtitle,
    };

/// Marks default [task]s done for the day and grants the routine reward.
class DefaultTaskCompletion {
  /// Records [task] as completed today (a completed `Activity`) and awards the
  /// same coins/strike as a routine. Idempotent per day — a no-op if the task
  /// is already completed today, so callers can fire it freely.
  static Future<void> complete({
    required DefaultTask task,
    required AdventureCubit adventure,
  }) async {
    try {
      if (await ActivityService.hasCompletedToday(task.id)) return;
      final docId = await ActivityService.createPendingActivity(
        sourceId: task.id,
        type: 'daily',
      );
      await ActivityService.completeActivity(docId, durationSeconds: 0);
      await adventure.awardForCompletion(task.xp);
      debugPrint('[DefaultTaskCompletion] completed ${task.id}');
    } catch (e) {
      debugPrint('[DefaultTaskCompletion] complete failed for ${task.id}: $e');
    }
  }
}
