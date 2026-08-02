import 'package:equatable/equatable.dart';

import '../../home/services/heart_service.dart';
import '../models/game_profile.dart';

/// UI state for the coin / strike / adventure system.
class AdventureState extends Equatable {
  final GameProfile profile;

  /// Current wall-clock (epoch millis), refreshed on a timer so time-based
  /// progress (the walking bar) advances and flips to "arrived" on its own.
  final int nowMs;

  /// Bumped on every awarded completion — a one-shot signal the home page
  /// listens to so it can fire confetti.
  final int rewardNonce;

  const AdventureState({
    this.profile = const GameProfile(),
    this.nowMs = 0,
    this.rewardNonce = 0,
  });

  bool get isReady => profile.isReady;
  bool get isWalking => profile.isWalking;

  /// Live hearts, settled against the clock (decays as [nowMs] advances).
  int get hearts =>
      HeartService.settle(profile.hearts, profile.heartsUpdatedAt, nowMs).hearts;

  /// True once the walking window has elapsed — the surprise is ready.
  bool get isArrived {
    final end = profile.adventureEndMs;
    return profile.isWalking && end != null && nowMs >= end;
  }

  /// Charging bar fraction (strikes toward the current level's goal).
  double get chargeProgress =>
      (profile.strikes / profile.strikeGoal).clamp(0.0, 1.0);

  /// Walking loading fraction (elapsed time toward the end).
  double get walkProgress {
    final start = profile.adventureStartMs;
    final end = profile.adventureEndMs;
    if (start == null || end == null || end <= start) return 0;
    return ((nowMs - start) / (end - start)).clamp(0.0, 1.0);
  }

  /// Time left before the adventure completes.
  Duration get remaining {
    final end = profile.adventureEndMs;
    if (end == null) return Duration.zero;
    final ms = end - nowMs;
    return ms <= 0 ? Duration.zero : Duration(milliseconds: ms);
  }

  AdventureState copyWith({
    GameProfile? profile,
    int? nowMs,
    int? rewardNonce,
  }) => AdventureState(
    profile: profile ?? this.profile,
    nowMs: nowMs ?? this.nowMs,
    rewardNonce: rewardNonce ?? this.rewardNonce,
  );

  @override
  List<Object?> get props => [profile, nowMs, rewardNonce];
}
