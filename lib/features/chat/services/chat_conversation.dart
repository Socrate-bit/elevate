import 'package:equatable/equatable.dart';

/// Top-level conversation document. Messages live in a subcollection.
///
/// [summary] / [summaryAt] / [memoryExtracted] are written by the memory
/// extractor when a session ends. [memoryExtracted] flips back to false the
/// next time the user sends a message in the conversation so the next quit
/// re-extracts on top of the prior data.
class ChatConversation extends Equatable {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final String summary;
  final DateTime? summaryAt;
  final bool memoryExtracted;

  const ChatConversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastMessageAt,
    this.summary = '',
    this.summaryAt,
    this.memoryExtracted = false,
  });

  ChatConversation copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    String? summary,
    DateTime? summaryAt,
    bool? memoryExtracted,
  }) => ChatConversation(
    id: id ?? this.id,
    title: title ?? this.title,
    createdAt: createdAt ?? this.createdAt,
    lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    summary: summary ?? this.summary,
    summaryAt: summaryAt ?? this.summaryAt,
    memoryExtracted: memoryExtracted ?? this.memoryExtracted,
  );

  Map<String, dynamic> toMap() => {
    'title': title,
    'createdAtMs': createdAt.millisecondsSinceEpoch,
    'lastMessageAtMs': lastMessageAt.millisecondsSinceEpoch,
    'summary': summary,
    'summaryAtMs': summaryAt?.millisecondsSinceEpoch,
    'memoryExtracted': memoryExtracted,
  };

  static ChatConversation fromMap(String id, Map<String, dynamic> m) {
    final summaryMs = m['summaryAtMs'];
    return ChatConversation(
      id: id,
      title: m['title'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        m['createdAtMs'] as int? ?? 0,
      ),
      lastMessageAt: DateTime.fromMillisecondsSinceEpoch(
        m['lastMessageAtMs'] as int? ?? m['createdAtMs'] as int? ?? 0,
      ),
      summary: m['summary'] as String? ?? '',
      summaryAt: summaryMs is int
          ? DateTime.fromMillisecondsSinceEpoch(summaryMs)
          : null,
      memoryExtracted: m['memoryExtracted'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    createdAt,
    lastMessageAt,
    summary,
    summaryAt,
    memoryExtracted,
  ];
}
