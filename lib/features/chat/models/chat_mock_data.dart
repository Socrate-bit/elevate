import 'package:equatable/equatable.dart';

/// A single chat bubble in the Appy "Forest Friend" conversation.
class ChatBubbleMessage extends Equatable {
  /// Whether the message is from the user (right, green) or Appy (left, white).
  final bool isUser;
  final String text;

  /// Optional sent time shown under user bubbles (e.g. "9:41 AM").
  final String? time;

  const ChatBubbleMessage({
    required this.isUser,
    required this.text,
    this.time,
  });

  @override
  List<Object?> get props => [isUser, text, time];
}

/// Hardcoded mock content for the Appy chat page — simulates backend data,
/// mirroring how `HomeMockData` seeds the home page.
class ChatMockData {
  // Demo conversation shown on first open.
  static const messages = [
    ChatBubbleMessage(isUser: false, text: 'Hey Lucas 🌸'),
    ChatBubbleMessage(isUser: false, text: "I'm here with you."),
    ChatBubbleMessage(
      isUser: false,
      text: "Whatever today has been like, it's okay.",
    ),
    ChatBubbleMessage(
      isUser: false,
      text: "You don't need to figure everything out at once.",
    ),
    ChatBubbleMessage(
      isUser: false,
      text: 'What would you like to talk about?',
    ),
    ChatBubbleMessage(
      isUser: true,
      text: 'I had a stressful day.',
      time: '9:41 AM',
    ),
  ];
}

/// A starter suggestion chip in the "Start a conversation" card.
class ChatSuggestion {
  final String emoji;
  final String label;

  const ChatSuggestion({required this.emoji, required this.label});
}
