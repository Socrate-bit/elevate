import 'package:equatable/equatable.dart';

/// Mission suggestion attached to a model message.
/// Produced when Gemini invokes the `suggest_mission` function tool.
class ChatMissionSuggestion extends Equatable {
  /// Raw MissionType enum name (e.g. 'pushUps'). Resolved via missionTypeFromString() at display time.
  final String missionType;

  /// One-sentence AI rationale shown to the user.
  final String reason;

  /// null = pending, true = accepted, false = declined.
  final bool? accepted;

  const ChatMissionSuggestion({
    required this.missionType,
    required this.reason,
    this.accepted,
  });

  ChatMissionSuggestion copyWith({
    String? missionType,
    String? reason,
    bool? accepted,
  }) => ChatMissionSuggestion(
    missionType: missionType ?? this.missionType,
    reason: reason ?? this.reason,
    accepted: accepted ?? this.accepted,
  );

  Map<String, dynamic> toMap() => {
    'missionType': missionType,
    'reason': reason,
    if (accepted != null) 'accepted': accepted,
  };

  static ChatMissionSuggestion fromMap(Map<String, dynamic> m) =>
      ChatMissionSuggestion(
        missionType: m['missionType'] as String? ?? 'random',
        reason: m['reason'] as String? ?? '',
        accepted: m['accepted'] as bool?,
      );

  @override
  List<Object?> get props => [missionType, reason, accepted];
}
