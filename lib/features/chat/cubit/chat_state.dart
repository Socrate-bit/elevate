import 'package:equatable/equatable.dart';

import '../services/chat_message.dart';

/// State for an active conversation. Mirrors the Firestore message stream
/// and tracks transient UI flags for the composer (sending, listening).
class ChatState extends Equatable {
  final String conversationId;
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isSending;
  final bool isListening;
  final String voicePartial;

  const ChatState({
    required this.conversationId,
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.isListening = false,
    this.voicePartial = '',
  });

  ChatState copyWith({
    String? conversationId,
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isSending,
    bool? isListening,
    String? voicePartial,
  }) => ChatState(
    conversationId: conversationId ?? this.conversationId,
    messages: messages ?? this.messages,
    isLoading: isLoading ?? this.isLoading,
    isSending: isSending ?? this.isSending,
    isListening: isListening ?? this.isListening,
    voicePartial: voicePartial ?? this.voicePartial,
  );

  @override
  List<Object?> get props => [
    conversationId,
    messages,
    isLoading,
    isSending,
    isListening,
    voicePartial,
  ];
}
