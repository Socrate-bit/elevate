import 'package:equatable/equatable.dart';

/// Strikes needed to fill the adventure bar before it can be started.
const kStrikeGoal = 30;

/// Base loading time once the pet leaves on an adventure.
const kAdventureDuration = Duration(hours: 8);

/// Every this-many strikes earned while walking shaves [kReductionPerStep] off
/// the remaining adventure time.
const kStrikesPerReduction = 10;
const kReductionPerStep = Duration(minutes: 20);

/// Adventure lifecycle phase.
/// - [charging]: strikes accumulate toward [kStrikeGoal]; once full the UI
///   surfaces a "Start Adventure" button (derived, see [GameProfile.isReady]).
/// - [walking]: the pet is away; strikes now count up to shorten the timer.
enum AdventurePhase { charging, walking }

/// Per-user gamification state (coins + adventure), persisted at
/// `users/{uid}/meta/game`. Equatable so cubit emits are deduped.
class GameProfile extends Equatable {
  /// Compounding coin total (spendable in a future shop).
  final int coins;

  /// Strike count. Meaning depends on [phase]:
  /// - charging: 0..[kStrikeGoal] (fills the adventure bar).
  /// - walking: counts up from 0, driving the timer reductions.
  final int strikes;

  final AdventurePhase phase;

  /// Walking window, epoch millis. Null while charging.
  final int? adventureStartMs;
  final int? adventureEndMs;

  /// Ids of earned wisdom trophies (append-only; length == adventures done).
  final List<String> trophies;

  const GameProfile({
    this.coins = 0,
    this.strikes = 0,
    this.phase = AdventurePhase.charging,
    this.adventureStartMs,
    this.adventureEndMs,
    this.trophies = const [],
  });

  /// True while charging and the bar is full — ready to start an adventure.
  bool get isReady => phase == AdventurePhase.charging && strikes >= kStrikeGoal;

  bool get isWalking => phase == AdventurePhase.walking;

  factory GameProfile.fromMap(Map<String, dynamic> data) => GameProfile(
    coins: (data['coins'] as int?) ?? 0,
    strikes: (data['strikes'] as int?) ?? 0,
    phase: (data['phase'] as String?) == 'walking'
        ? AdventurePhase.walking
        : AdventurePhase.charging,
    adventureStartMs: data['adventureStartMs'] as int?,
    adventureEndMs: data['adventureEndMs'] as int?,
    trophies: List<String>.from(data['trophies'] as List? ?? const []),
  );

  Map<String, dynamic> toMap() => {
    'coins': coins,
    'strikes': strikes,
    'phase': phase == AdventurePhase.walking ? 'walking' : 'charging',
    'adventureStartMs': adventureStartMs,
    'adventureEndMs': adventureEndMs,
    'trophies': trophies,
  };

  GameProfile copyWith({
    int? coins,
    int? strikes,
    AdventurePhase? phase,
    int? adventureStartMs,
    int? adventureEndMs,
    List<String>? trophies,
    bool clearWindow = false,
  }) => GameProfile(
    coins: coins ?? this.coins,
    strikes: strikes ?? this.strikes,
    phase: phase ?? this.phase,
    adventureStartMs: clearWindow ? null : (adventureStartMs ?? this.adventureStartMs),
    adventureEndMs: clearWindow ? null : (adventureEndMs ?? this.adventureEndMs),
    trophies: trophies ?? this.trophies,
  );

  @override
  List<Object?> get props => [
    coins,
    strikes,
    phase,
    adventureStartMs,
    adventureEndMs,
    trophies,
  ];
}
