import 'package:equatable/equatable.dart';

/// A single life event mentioned by the user in chat, extracted into its own
/// document. One conversation may produce many events.
class LifeEvent extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime? occurredAt;
  final String sourceConversationId;
  final DateTime createdAt;

  const LifeEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.sourceConversationId,
    required this.createdAt,
    this.occurredAt,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'occurredAtMs': occurredAt?.millisecondsSinceEpoch,
        'sourceConversationId': sourceConversationId,
        'createdAtMs': createdAt.millisecondsSinceEpoch,
      };

  static LifeEvent fromMap(String id, Map<String, dynamic> m) {
    final occMs = m['occurredAtMs'];
    return LifeEvent(
      id: id,
      title: m['title'] as String? ?? '',
      description: m['description'] as String? ?? '',
      occurredAt:
          occMs is int ? DateTime.fromMillisecondsSinceEpoch(occMs) : null,
      sourceConversationId: m['sourceConversationId'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        m['createdAtMs'] as int? ?? 0,
      ),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        occurredAt,
        sourceConversationId,
        createdAt,
      ];
}
