import 'package:equatable/equatable.dart';

/// App-wide state for the pet's daily engagement: the streak (distinct active
/// days) and hearts (pet health), both derived from the activity stream.
class StreakState extends Equatable {
  /// Current streak, in distinct active days.
  final int streak;

  /// Remaining hearts (pet health), decaying with inactivity.
  final int hearts;

  final bool loading;

  const StreakState({
    this.streak = 0,
    this.hearts = 0,
    this.loading = true,
  });

  StreakState copyWith({
    int? streak,
    int? hearts,
    bool? loading,
  }) => StreakState(
    streak: streak ?? this.streak,
    hearts: hearts ?? this.hearts,
    loading: loading ?? this.loading,
  );

  @override
  List<Object?> get props => [streak, hearts, loading];
}
