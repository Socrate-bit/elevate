import 'package:equatable/equatable.dart';

import '../services/chat_message.dart';

/// State for an active conversation. Mirrors the Firestore message stream and
/// tracks transient UI flags for the composer (sending, listening). Insight
/// progress + boundary are mirrored from [MemoryCubit] (the background builder
/// owns them now).
class ChatState extends Equatable {
  final String conversationId;
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isSending;
  final bool isListening;
  final String voicePartial;

  /// True while an insight is being generated (drives the forming animation).
  final bool isGeneratingInsight;

  /// AI-suggested rapid replies for the latest assistant turn (0–4). Surfaced
  /// by the composer's rapid-answer button; cleared when the user sends.
  final List<String> proposedAnswers;

  /// Model-assessed readiness of the conversation to yield an insight, [0,1].
  /// Mirrored from the memory builder's state.
  final double insightProgress;

  /// createdAtMs of the last generated insight; progress + turn counting reset
  /// for messages newer than this.
  final int insightBoundaryMs;

  const ChatState({
    required this.conversationId,
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.isListening = false,
    this.voicePartial = '',
    this.isGeneratingInsight = false,
    this.proposedAnswers = const [],
    this.insightProgress = 0.0,
    this.insightBoundaryMs = 0,
  });

  ChatState copyWith({
    String? conversationId,
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isSending,
    bool? isListening,
    String? voicePartial,
    bool? isGeneratingInsight,
    List<String>? proposedAnswers,
    double? insightProgress,
    int? insightBoundaryMs,
  }) => ChatState(
    conversationId: conversationId ?? this.conversationId,
    messages: messages ?? this.messages,
    isLoading: isLoading ?? this.isLoading,
    isSending: isSending ?? this.isSending,
    isListening: isListening ?? this.isListening,
    voicePartial: voicePartial ?? this.voicePartial,
    isGeneratingInsight: isGeneratingInsight ?? this.isGeneratingInsight,
    proposedAnswers: proposedAnswers ?? this.proposedAnswers,
    insightProgress: insightProgress ?? this.insightProgress,
    insightBoundaryMs: insightBoundaryMs ?? this.insightBoundaryMs,
  );

  /// Number of user turns since the most recent insight (by the memory
  /// builder's boundary). Drives the auto-generate trigger.
  int get userTurnsSinceLastInsight {
    var count = 0;
    for (final m in messages) {
      if (m.role != ChatRole.user) continue;
      if (m.createdAt.millisecondsSinceEpoch > insightBoundaryMs) count++;
    }
    return count;
  }

  /// Messages accumulated since the most recent insight, chronological.
  List<ChatMessage> get messagesSinceLastInsight => messages
      .where((m) => m.createdAt.millisecondsSinceEpoch > insightBoundaryMs)
      .toList();

  @override
  List<Object?> get props => [
    conversationId,
    messages,
    isLoading,
    isSending,
    isListening,
    voicePartial,
    isGeneratingInsight,
    proposedAnswers,
    insightProgress,
    insightBoundaryMs,
  ];
}
