import 'package:equatable/equatable.dart';

import '../models/life_event.dart';
import '../models/life_rating.dart';
import '../models/memory_profile.dart';
import '../models/memory_summary.dart';

/// The user's reactive memory: durable facts, life events, rolling
/// conversation summaries, the life rating, and the insight progress/boundary
/// maintained by the background builder. Fed to the Answerer on every turn.
class MemoryState extends Equatable {
  final MemoryProfile profile;
  final List<LifeEvent> events;
  final List<MemorySummary> summaries;
  final LifeRating lifeRating;
  final double insightProgress;
  final int insightBoundaryMs;
  final bool isLoading;

  const MemoryState({
    required this.profile,
    required this.events,
    required this.summaries,
    required this.lifeRating,
    required this.insightProgress,
    required this.insightBoundaryMs,
    required this.isLoading,
  });

  factory MemoryState.initial() => MemoryState(
    profile: MemoryProfile.empty(),
    events: const [],
    summaries: const [],
    lifeRating: LifeRating.empty(),
    insightProgress: 0.0,
    insightBoundaryMs: 0,
    isLoading: true,
  );

  MemoryState copyWith({
    MemoryProfile? profile,
    List<LifeEvent>? events,
    List<MemorySummary>? summaries,
    LifeRating? lifeRating,
    double? insightProgress,
    int? insightBoundaryMs,
    bool? isLoading,
  }) => MemoryState(
    profile: profile ?? this.profile,
    events: events ?? this.events,
    summaries: summaries ?? this.summaries,
    lifeRating: lifeRating ?? this.lifeRating,
    insightProgress: insightProgress ?? this.insightProgress,
    insightBoundaryMs: insightBoundaryMs ?? this.insightBoundaryMs,
    isLoading: isLoading ?? this.isLoading,
  );

  @override
  List<Object?> get props => [
    profile,
    events,
    summaries,
    lifeRating,
    insightProgress,
    insightBoundaryMs,
    isLoading,
  ];
}
