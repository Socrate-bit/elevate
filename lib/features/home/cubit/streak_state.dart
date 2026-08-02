import 'package:equatable/equatable.dart';

/// App-wide state for the pet's daily streak (distinct active days), derived
/// from the activity stream and bounded by the hearts-zero anchor. Hearts now
/// live on the game profile (see `AdventureState.hearts`).
class StreakState extends Equatable {
  /// Current streak, in distinct active days.
  final int streak;

  /// Longest historical streak, in distinct active days.
  final int bestStreak;

  final bool loading;

  const StreakState({
    this.streak = 0,
    this.bestStreak = 0,
    this.loading = true,
  });

  StreakState copyWith({
    int? streak,
    int? bestStreak,
    bool? loading,
  }) => StreakState(
    streak: streak ?? this.streak,
    bestStreak: bestStreak ?? this.bestStreak,
    loading: loading ?? this.loading,
  );

  @override
  List<Object?> get props => [streak, bestStreak, loading];
}
