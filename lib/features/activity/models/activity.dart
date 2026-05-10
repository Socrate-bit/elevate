import 'package:equatable/equatable.dart';

/// A logged user activity (e.g. an alarm dismissal). Feeds streaks and insights.
class Activity extends Equatable {
  final String id;
  final String? sourceId; // e.g. alarmId; null for ad-hoc activities
  final DateTime timestamp;
  final int durationSeconds;
  final String type; // free-form domain string, e.g. 'alarm_stop'
  final bool completed;

  const Activity({
    required this.id,
    this.sourceId,
    required this.timestamp,
    required this.durationSeconds,
    this.type = 'default',
    this.completed = true,
  });

  Map<String, dynamic> toFirestore() => {
        'sourceId': sourceId,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'durationSeconds': durationSeconds,
        'type': type,
        'completed': completed,
      };

  factory Activity.fromFirestore(String id, Map<String, dynamic> data) {
    return Activity(
      id: id,
      sourceId: data['sourceId'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (data['timestamp'] as int?) ?? 0,
      ),
      durationSeconds: (data['durationSeconds'] as int?) ?? 0,
      type: (data['type'] as String?) ?? 'default',
      completed: (data['completed'] as bool?) ?? true,
    );
  }

  @override
  List<Object?> get props =>
      [id, sourceId, timestamp, durationSeconds, type, completed];
}
