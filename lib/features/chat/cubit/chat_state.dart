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

  /// True while an insight is being generated (drives the forming animation).
  final bool isGeneratingInsight;

  const ChatState({
    required this.conversationId,
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.isListening = false,
    this.voicePartial = '',
    this.isGeneratingInsight = false,
  });

  ChatState copyWith({
    String? conversationId,
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isSending,
    bool? isListening,
    String? voicePartial,
    bool? isGeneratingInsight,
  }) => ChatState(
    conversationId: conversationId ?? this.conversationId,
    messages: messages ?? this.messages,
    isLoading: isLoading ?? this.isLoading,
    isSending: isSending ?? this.isSending,
    isListening: isListening ?? this.isListening,
    voicePartial: voicePartial ?? this.voicePartial,
    isGeneratingInsight: isGeneratingInsight ?? this.isGeneratingInsight,
  );

  /// Model-assessed readiness of the current conversation to yield an insight,
  /// in [0,1] — the stored progress of the latest model turn since the last
  /// insight, falling back to 0.0. Reaches 1.0 when the model judges an insight
  /// can be generated. Drives the ring; read from messages, never recomputed.
  double get insightProgress {
    for (final m in messages.reversed) {
      if (m.insight != null) break; // reset boundary
      if (m.insightProgress != null) return m.insightProgress!;
    }
    return 0.0;
  }

  /// Number of user turns since the most recent insight message (all user
  /// turns if there is no insight yet). Drives the progress ring + triggers.
  int get userTurnsSinceLastInsight {
    var count = 0;
    for (final m in messages.reversed) {
      if (m.insight != null) break;
      if (m.role == ChatRole.user) count++;
    }
    return count;
  }

  /// Messages accumulated since the most recent insight (all of them if there
  /// is none yet), in chronological order. Feeds the model-driven progress
  /// assessment so readiness resets after each insight.
  List<ChatMessage> get messagesSinceLastInsight {
    final out = <ChatMessage>[];
    for (final m in messages.reversed) {
      if (m.insight != null) break;
      out.add(m);
    }
    return out.reversed.toList();
  }

  @override
  List<Object?> get props => [
    conversationId,
    messages,
    isLoading,
    isSending,
    isListening,
    voicePartial,
    isGeneratingInsight,
  ];
}
