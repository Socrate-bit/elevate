import 'package:equatable/equatable.dart';

/// Guided-activity suggestion attached to a model message. Produced when Gemini
/// invokes the `suggest_mission` function tool. [toolKey] is a stable
/// `ToolItem.key` (breathing, meditation, stretching, gratitude…) resolved to a
/// tool at display time so the card can render it and open its session.
class ChatMissionSuggestion extends Equatable {
  final String toolKey;

  /// One-sentence AI rationale shown to the user.
  final String reason;

  /// null = pending, true = started, false = declined.
  final bool? accepted;

  const ChatMissionSuggestion({
    required this.toolKey,
    required this.reason,
    this.accepted,
  });

  ChatMissionSuggestion copyWith({
    String? toolKey,
    String? reason,
    bool? accepted,
  }) => ChatMissionSuggestion(
    toolKey: toolKey ?? this.toolKey,
    reason: reason ?? this.reason,
    accepted: accepted ?? this.accepted,
  );

  Map<String, dynamic> toMap() => {
    'toolKey': toolKey,
    'reason': reason,
    if (accepted != null) 'accepted': accepted,
  };

  static ChatMissionSuggestion fromMap(Map<String, dynamic> m) =>
      ChatMissionSuggestion(
        // 'missionType' kept as a legacy fallback for older stored messages.
        toolKey: m['toolKey'] as String? ?? m['missionType'] as String? ?? '',
        reason: m['reason'] as String? ?? '',
        accepted: m['accepted'] as bool?,
      );

  @override
  List<Object?> get props => [toolKey, reason, accepted];
}
