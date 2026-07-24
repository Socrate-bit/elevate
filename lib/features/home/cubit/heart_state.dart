import 'package:equatable/equatable.dart';

/// App-wide pet health + streak state. Hearts decay with inactivity and drive
/// the pet's mood; the streak breaks permanently when hearts fully deplete.
class HeartState extends Equatable {
  /// Remaining hearts, 0..kHeartMax.
  final int hearts;

  /// Current daily streak (0 while broken / no activity).
  final int streak;

  final bool loading;

  const HeartState({
    this.hearts = 0,
    this.streak = 0,
    this.loading = true,
  });

  HeartState copyWith({
    int? hearts,
    int? streak,
    bool? loading,
  }) => HeartState(
    hearts: hearts ?? this.hearts,
    streak: streak ?? this.streak,
    loading: loading ?? this.loading,
  );

  @override
  List<Object?> get props => [hearts, streak, loading];
}
