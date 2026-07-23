import 'package:equatable/equatable.dart';

/// Model for an AI-generated insight card rendered inline in the chat.
///
/// Distilled from the conversation so far: one [title], one key [quote] pulled
/// from the chat, and a short [body] paragraph that teaches or unlocks something.
class ChatInsight extends Equatable {
  final String title;
  final String quote; // key citation from the conversation
  final String body; // the insight itself (short paragraph)

  const ChatInsight({
    required this.title,
    required this.quote,
    required this.body,
  });

  ChatInsight copyWith({String? title, String? quote, String? body}) =>
      ChatInsight(
        title: title ?? this.title,
        quote: quote ?? this.quote,
        body: body ?? this.body,
      );

  Map<String, dynamic> toMap() => {
    'title': title,
    'quote': quote,
    'body': body,
  };

  factory ChatInsight.fromMap(Map<String, dynamic> m) => ChatInsight(
    title: m['title'] as String? ?? '',
    quote: m['quote'] as String? ?? '',
    body: m['body'] as String? ?? '',
  );

  @override
  List<Object?> get props => [title, quote, body];
}
