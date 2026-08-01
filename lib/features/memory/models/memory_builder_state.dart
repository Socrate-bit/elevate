import 'package:equatable/equatable.dart';

/// Bookkeeping for the background memory builder, stored at
/// `users/{uid}/memory/state`. Centralizes the analysis watermark and the
/// insight progress/boundary (which used to live per-message).
class MemoryBuilderState extends Equatable {
  /// The builder has processed every message with `createdAtMs <= analyzedUpToMs`.
  final int analyzedUpToMs;

  /// Model-assessed readiness of the conversation to yield an insight, [0,1].
  final double insightProgress;

  /// createdAtMs of the last generated insight message. Progress and the
  /// turn-count reset for messages newer than this.
  final int insightBoundaryMs;
  final DateTime updatedAt;

  const MemoryBuilderState({
    required this.analyzedUpToMs,
    required this.insightProgress,
    required this.insightBoundaryMs,
    required this.updatedAt,
  });

  factory MemoryBuilderState.initial() => MemoryBuilderState(
    analyzedUpToMs: 0,
    insightProgress: 0.0,
    insightBoundaryMs: 0,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  Map<String, dynamic> toMap() => {
    'analyzedUpToMs': analyzedUpToMs,
    'insightProgress': insightProgress,
    'insightBoundaryMs': insightBoundaryMs,
    'updatedAtMs': updatedAt.millisecondsSinceEpoch,
  };

  static MemoryBuilderState fromMap(Map<String, dynamic> m) => MemoryBuilderState(
    analyzedUpToMs: m['analyzedUpToMs'] as int? ?? 0,
    insightProgress: (m['insightProgress'] as num?)?.toDouble() ?? 0.0,
    insightBoundaryMs: m['insightBoundaryMs'] as int? ?? 0,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(m['updatedAtMs'] as int? ?? 0),
  );

  @override
  List<Object?> get props => [
    analyzedUpToMs,
    insightProgress,
    insightBoundaryMs,
    updatedAt,
  ];
}
