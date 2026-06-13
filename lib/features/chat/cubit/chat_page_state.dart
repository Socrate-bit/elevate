import 'package:equatable/equatable.dart';

import '../models/chat_mock_data.dart';

/// State of the new illustrated chat page ("Forest Friend").
class ChatPageState extends Equatable {
  final List<ChatBubbleMessage> messages;

  /// Whether the "Start a conversation" suggestions card is visible.
  final bool showSuggestions;

  const ChatPageState({
    this.messages = ChatMockData.messages,
    this.showSuggestions = true,
  });

  ChatPageState copyWith({
    List<ChatBubbleMessage>? messages,
    bool? showSuggestions,
  }) => ChatPageState(
    messages: messages ?? this.messages,
    showSuggestions: showSuggestions ?? this.showSuggestions,
  );

  @override
  List<Object?> get props => [messages, showSuggestions];
}
