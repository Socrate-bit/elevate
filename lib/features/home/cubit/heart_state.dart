import 'package:equatable/equatable.dart';

/// App-wide pet health state. Hearts decay with inactivity and drive the pet's
/// mood animation.
class HeartState extends Equatable {
  /// Remaining hearts, 0..kHeartMax.
  final int hearts;

  final bool loading;

  const HeartState({
    this.hearts = 0,
    this.loading = true,
  });

  HeartState copyWith({
    int? hearts,
    bool? loading,
  }) => HeartState(
    hearts: hearts ?? this.hearts,
    loading: loading ?? this.loading,
  );

  @override
  List<Object?> get props => [hearts, loading];
}
