import 'package:equatable/equatable.dart';

/// A user-defined trackable item. Two flavors:
/// - [RoutineType.action]: persistent until validated or deleted; optionally
///   scheduled for a specific date + time.
/// - [RoutineType.habit]: recurring on `scheduledDays` (Sun..Sat) at
///   `scheduledMinute`.
enum RoutineType { action, habit }

class Routine extends Equatable {
  final String id;
  final RoutineType type;
  final String name;
  final String? description;

  /// Emoji shown on the routine's tile (e.g. '🧘'). See `kRoutineEmojis`.
  final String emoji;

  /// Key into `kRoutineColors` (routine_palette.dart).
  final String colorKey;

  /// Points awarded/displayed for completing this routine (display-only).
  final int xp;

  /// Free-text object name for photo validation. Null = no object check.
  final String? objectCheck;

  /// Action-only: specific date (date portion only). Null = not scheduled.
  final DateTime? scheduledDate;

  /// Habit-only: 7 booleans, index 0 = Sunday … 6 = Saturday.
  final List<bool> scheduledDays;

  /// Minutes since midnight; null = no time set.
  final int? scheduledMinute;

  /// User opted in to a native alarm at the scheduled moment.
  final bool hasAlarm;

  /// Native alarm id returned by `AlarmChannel.schedule*`. Null = none scheduled.
  final String? nativeAlarmId;

  /// Stable [ToolItem.key] when this routine is an activity/tool task. Non-null
  /// means tapping the card opens that tool's guided session (meditation,
  /// stretching, breathing…) instead of the edit form.
  final String? toolKey;

  final DateTime createdAt;

  Routine({
    required this.id,
    required this.type,
    required this.name,
    this.description,
    required this.emoji,
    required this.colorKey,
    this.xp = 10,
    this.objectCheck,
    this.scheduledDate,
    this.scheduledDays = const [false, false, false, false, false, false, false],
    this.scheduledMinute,
    this.hasAlarm = false,
    this.nativeAlarmId,
    this.toolKey,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isScheduledToday {
    final now = DateTime.now();
    if (type == RoutineType.habit) {
      final weekdayIndex = now.weekday % 7; // Sun=0..Sat=6
      return scheduledDays.length > weekdayIndex &&
          scheduledDays[weekdayIndex];
    }
    if (scheduledDate == null) return false;
    return scheduledDate!.year == now.year &&
        scheduledDate!.month == now.month &&
        scheduledDate!.day == now.day;
  }

  /// True if this routine should block the day for streak purposes.
  /// Habits only block on their scheduled day; actions always block until done.
  bool isExpectedOn(DateTime day) {
    if (type == RoutineType.action) return true;
    final weekdayIndex = day.weekday % 7;
    return scheduledDays.length > weekdayIndex &&
        scheduledDays[weekdayIndex];
  }

  Routine copyWith({
    String? id,
    RoutineType? type,
    String? name,
    String? description,
    bool clearDescription = false,
    String? emoji,
    String? colorKey,
    int? xp,
    String? objectCheck,
    bool clearObjectCheck = false,
    DateTime? scheduledDate,
    bool clearScheduledDate = false,
    List<bool>? scheduledDays,
    int? scheduledMinute,
    bool clearScheduledMinute = false,
    bool? hasAlarm,
    String? nativeAlarmId,
    bool clearNativeAlarmId = false,
    String? toolKey,
    bool clearToolKey = false,
    DateTime? createdAt,
  }) =>
      Routine(
        id: id ?? this.id,
        type: type ?? this.type,
        name: name ?? this.name,
        description:
            clearDescription ? null : (description ?? this.description),
        emoji: emoji ?? this.emoji,
        colorKey: colorKey ?? this.colorKey,
        xp: xp ?? this.xp,
        objectCheck:
            clearObjectCheck ? null : (objectCheck ?? this.objectCheck),
        scheduledDate:
            clearScheduledDate ? null : (scheduledDate ?? this.scheduledDate),
        scheduledDays: scheduledDays ?? this.scheduledDays,
        scheduledMinute: clearScheduledMinute
            ? null
            : (scheduledMinute ?? this.scheduledMinute),
        hasAlarm: hasAlarm ?? this.hasAlarm,
        nativeAlarmId:
            clearNativeAlarmId ? null : (nativeAlarmId ?? this.nativeAlarmId),
        toolKey: clearToolKey ? null : (toolKey ?? this.toolKey),
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [
        id,
        type,
        name,
        description,
        emoji,
        colorKey,
        xp,
        objectCheck,
        scheduledDate,
        scheduledDays,
        scheduledMinute,
        hasAlarm,
        nativeAlarmId,
        toolKey,
        createdAt,
      ];
}
