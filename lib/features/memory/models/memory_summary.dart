import 'package:equatable/equatable.dart';

/// A smartly-segmented recap of part of the ongoing conversation. The memory
/// builder maintains a rolling list of these: it updates the most recent one
/// while the same topic/session continues, and creates a new one when the
/// conversation moves on. Replaces the old one-summary-per-conversation model.
class MemorySummary extends Equatable {
  final String id;

  /// A few-sentence recap of what was discussed in this segment.
  final String text;

  /// Short label the builder assigns for segmentation (e.g. "job stress").
  final String topic;

  /// createdAt of the earliest message this summary covers.
  final DateTime startedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MemorySummary({
    required this.id,
    required this.text,
    required this.topic,
    required this.startedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'text': text,
    'topic': topic,
    'startedAtMs': startedAt.millisecondsSinceEpoch,
    'createdAtMs': createdAt.millisecondsSinceEpoch,
    'updatedAtMs': updatedAt.millisecondsSinceEpoch,
  };

  static MemorySummary fromMap(String id, Map<String, dynamic> m) => MemorySummary(
    id: id,
    text: m['text'] as String? ?? '',
    topic: m['topic'] as String? ?? '',
    startedAt: DateTime.fromMillisecondsSinceEpoch(m['startedAtMs'] as int? ?? 0),
    createdAt: DateTime.fromMillisecondsSinceEpoch(m['createdAtMs'] as int? ?? 0),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(m['updatedAtMs'] as int? ?? 0),
  );

  @override
  List<Object?> get props => [id, text, topic, startedAt, createdAt, updatedAt];
}
