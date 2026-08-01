import 'package:equatable/equatable.dart';

/// A single life event the user mentioned in chat, extracted into its own
/// document. The memory builder can create, update, or delete these over time.
class LifeEvent extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime? occurredAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LifeEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.occurredAt,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'occurredAtMs': occurredAt?.millisecondsSinceEpoch,
    'createdAtMs': createdAt.millisecondsSinceEpoch,
    'updatedAtMs': updatedAt.millisecondsSinceEpoch,
  };

  static LifeEvent fromMap(String id, Map<String, dynamic> m) {
    final occMs = m['occurredAtMs'];
    return LifeEvent(
      id: id,
      title: m['title'] as String? ?? '',
      description: m['description'] as String? ?? '',
      occurredAt: occMs is int ? DateTime.fromMillisecondsSinceEpoch(occMs) : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(m['createdAtMs'] as int? ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        m['updatedAtMs'] as int? ?? m['createdAtMs'] as int? ?? 0,
      ),
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    occurredAt,
    createdAt,
    updatedAt,
  ];
}
