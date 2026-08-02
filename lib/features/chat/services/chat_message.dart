import 'package:equatable/equatable.dart';

import 'chat_form.dart';
import 'chat_insight.dart';
import 'chat_mission_suggestion.dart';
import 'chat_mood_check_in.dart';
import 'chat_routine_mutation.dart';

/// Role of the author of a chat message.
enum ChatRole { user, model }

/// A single chat turn — either user text or a model reply (text, form,
/// mission suggestion, mood check-in, routine-mutation confirmation, or a
/// distilled insight).
class ChatMessage extends Equatable {
  final String id;
  final String conversationId;
  final ChatRole role;
  final String text;
  final ChatForm? form;
  final ChatMissionSuggestion? missionSuggestion;
  final ChatMoodCheckIn? moodCheckIn;
  final ChatRoutineMutation? routineMutation;
  final ChatInsight? insight;

  /// True once the user has opened this insight for the first time (only ever
  /// set on insight messages). Gates the one-time open reward + win page.
  final bool insightOpened;

  /// AI-suggested rapid replies attached to a model turn (0–4). Persisted on
  /// the message so they survive leaving/reopening the chat; surfaced by the
  /// composer only while this is the latest message.
  final List<String> proposedAnswers;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.text,
    required this.createdAt,
    this.form,
    this.missionSuggestion,
    this.moodCheckIn,
    this.routineMutation,
    this.insight,
    this.insightOpened = false,
    this.proposedAnswers = const [],
  });

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    ChatRole? role,
    String? text,
    ChatForm? form,
    ChatMissionSuggestion? missionSuggestion,
    ChatMoodCheckIn? moodCheckIn,
    ChatRoutineMutation? routineMutation,
    ChatInsight? insight,
    bool? insightOpened,
    List<String>? proposedAnswers,
    DateTime? createdAt,
  }) => ChatMessage(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    role: role ?? this.role,
    text: text ?? this.text,
    form: form ?? this.form,
    missionSuggestion: missionSuggestion ?? this.missionSuggestion,
    moodCheckIn: moodCheckIn ?? this.moodCheckIn,
    routineMutation: routineMutation ?? this.routineMutation,
    insight: insight ?? this.insight,
    insightOpened: insightOpened ?? this.insightOpened,
    proposedAnswers: proposedAnswers ?? this.proposedAnswers,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toMap() => {
    'role': role.name,
    'text': text,
    'form': form?.toMap(),
    'missionSuggestion': missionSuggestion?.toMap(),
    'moodCheckIn': moodCheckIn?.toMap(),
    'routineMutation': routineMutation?.toMap(),
    'insight': insight?.toMap(),
    'insightOpened': insightOpened,
    if (proposedAnswers.isNotEmpty) 'proposedAnswers': proposedAnswers,
    'createdAtMs': createdAt.millisecondsSinceEpoch,
  };

  static ChatMessage fromMap(
    String id,
    String conversationId,
    Map<String, dynamic> m,
  ) {
    final roleStr = m['role'] as String? ?? 'user';
    final formMap = m['form'] as Map<String, dynamic>?;
    final missionMap = m['missionSuggestion'] as Map<String, dynamic>?;
    final moodMap = m['moodCheckIn'] as Map<String, dynamic>?;
    final routineMap = m['routineMutation'] as Map<String, dynamic>?;
    final insightMap = m['insight'] as Map<String, dynamic>?;
    return ChatMessage(
      id: id,
      conversationId: conversationId,
      role: roleStr == 'model' ? ChatRole.model : ChatRole.user,
      text: m['text'] as String? ?? '',
      form: formMap == null ? null : ChatForm.fromMap(formMap),
      missionSuggestion: missionMap == null
          ? null
          : ChatMissionSuggestion.fromMap(missionMap),
      moodCheckIn: moodMap == null ? null : ChatMoodCheckIn.fromMap(moodMap),
      routineMutation: routineMap == null
          ? null
          : ChatRoutineMutation.fromMap(routineMap),
      insight: insightMap == null ? null : ChatInsight.fromMap(insightMap),
      insightOpened: m['insightOpened'] as bool? ?? false,
      proposedAnswers: (m['proposedAnswers'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        m['createdAtMs'] as int? ?? 0,
      ),
    );
  }

  @override
  List<Object?> get props => [
    id,
    conversationId,
    role,
    text,
    form,
    missionSuggestion,
    moodCheckIn,
    routineMutation,
    insight,
    insightOpened,
    proposedAnswers,
    createdAt,
  ];
}
