import 'package:equatable/equatable.dart';

/// Top-level conversation document. Messages live in a subcollection.
class ChatConversation extends Equatable {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastMessageAt;

  const ChatConversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastMessageAt,
  });

  ChatConversation copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? lastMessageAt,
  }) =>
      ChatConversation(
        id: id ?? this.id,
        title: title ?? this.title,
        createdAt: createdAt ?? this.createdAt,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'createdAtMs': createdAt.millisecondsSinceEpoch,
        'lastMessageAtMs': lastMessageAt.millisecondsSinceEpoch,
      };

  static ChatConversation fromMap(String id, Map<String, dynamic> m) =>
      ChatConversation(
        id: id,
        title: m['title'] as String? ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          m['createdAtMs'] as int? ?? 0,
        ),
        lastMessageAt: DateTime.fromMillisecondsSinceEpoch(
          m['lastMessageAtMs'] as int? ?? m['createdAtMs'] as int? ?? 0,
        ),
      );

  @override
  List<Object?> get props => [id, title, createdAt, lastMessageAt];
}
