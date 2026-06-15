import 'package:equatable/equatable.dart';

import '../models/memory_profile.dart';

/// Lightweight (conversationId, summary, lastMessageAt) record maintained by
/// [MemoryCubit] so [MemoryCubit.buildMemoryContext] can format a top-N list
/// quickly.
class ConversationSummary extends Equatable {
  final String conversationId;
  final String summary;
  final DateTime lastMessageAt;

  const ConversationSummary({
    required this.conversationId,
    required this.summary,
    required this.lastMessageAt,
  });

  @override
  List<Object?> get props => [conversationId, summary, lastMessageAt];
}

class MemoryState extends Equatable {
  final MemoryProfile profile;
  final List<ConversationSummary> recentSummaries;
  final bool isLoading;

  const MemoryState({
    required this.profile,
    required this.recentSummaries,
    required this.isLoading,
  });

  factory MemoryState.initial() => MemoryState(
        profile: MemoryProfile.empty(),
        recentSummaries: const [],
        isLoading: true,
      );

  MemoryState copyWith({
    MemoryProfile? profile,
    List<ConversationSummary>? recentSummaries,
    bool? isLoading,
  }) =>
      MemoryState(
        profile: profile ?? this.profile,
        recentSummaries: recentSummaries ?? this.recentSummaries,
        isLoading: isLoading ?? this.isLoading,
      );

  @override
  List<Object?> get props => [profile, recentSummaries, isLoading];
}
