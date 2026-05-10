import 'package:equatable/equatable.dart';

/// Local model for a scheduled alarm.
class AppAlarmEntry extends Equatable {
  final String id;
  final DateTime dateTime;
  final String name;
  final List<bool> repeatDays; // Sun=0 … Sat=6
  final bool isEnabled;
  final bool isOneTime;
  final DateTime createdAt;
  final bool disabledBySubscription;

  AppAlarmEntry({
    required this.id,
    required this.dateTime,
    this.name = '',
    this.repeatDays = const [false, true, true, true, true, true, false],
    this.isEnabled = true,
    this.isOneTime = false,
    this.disabledBySubscription = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  AppAlarmEntry copyWith({
    String? id,
    DateTime? dateTime,
    String? name,
    List<bool>? repeatDays,
    bool? isEnabled,
    bool? isOneTime,
    bool? disabledBySubscription,
    DateTime? createdAt,
  }) =>
      AppAlarmEntry(
        id: id ?? this.id,
        dateTime: dateTime ?? this.dateTime,
        name: name ?? this.name,
        repeatDays: repeatDays ?? this.repeatDays,
        isEnabled: isEnabled ?? this.isEnabled,
        isOneTime: isOneTime ?? this.isOneTime,
        disabledBySubscription:
            disabledBySubscription ?? this.disabledBySubscription,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [
        id,
        dateTime,
        name,
        repeatDays,
        isEnabled,
        isOneTime,
        disabledBySubscription,
        createdAt,
      ];
}

extension AppAlarmEntryFire on AppAlarmEntry {
  /// Next real fire time in the future, respecting [repeatDays]/[isOneTime].
  /// Returns null if the alarm has no upcoming fire.
  DateTime? nextFireAt(DateTime now) {
    if (!isEnabled) return null;
    if (isOneTime) {
      return dateTime.isAfter(now) ? dateTime : null;
    }
    for (int i = 0; i < 7; i++) {
      final candidateDay = DateTime(now.year, now.month, now.day).add(
        Duration(days: i),
      );
      final dayIndex = candidateDay.weekday % 7;
      if (repeatDays.length > dayIndex && repeatDays[dayIndex]) {
        final candidate = DateTime(
          candidateDay.year,
          candidateDay.month,
          candidateDay.day,
          dateTime.hour,
          dateTime.minute,
        );
        if (candidate.isAfter(now)) return candidate;
      }
    }
    return null;
  }
}

class AlarmState extends Equatable {
  final List<AppAlarmEntry> alarms;
  final bool isLoading;
  const AlarmState({this.alarms = const [], this.isLoading = false});

  AlarmState copyWith({List<AppAlarmEntry>? alarms, bool? isLoading}) =>
      AlarmState(
        alarms: alarms ?? this.alarms,
        isLoading: isLoading ?? this.isLoading,
      );

  @override
  List<Object?> get props => [alarms, isLoading];
}
