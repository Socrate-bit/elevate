import 'package:equatable/equatable.dart';

/// App-wide daily-streak state: consecutive days with a completed activity.
class StreakState extends Equatable {
  /// Current consecutive-day streak.
  final int streak;

  final bool loading;

  const StreakState({
    this.streak = 0,
    this.loading = true,
  });

  StreakState copyWith({
    int? streak,
    bool? loading,
  }) => StreakState(
    streak: streak ?? this.streak,
    loading: loading ?? this.loading,
  );

  @override
  List<Object?> get props => [streak, loading];
}
