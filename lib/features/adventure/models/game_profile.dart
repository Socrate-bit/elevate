import 'package:equatable/equatable.dart';

import '../../home/services/heart_service.dart';

/// Leaves ("strikes") the user must earn in a day to send the pet on its
/// adventure. Fixed daily goal — the premade routine grows exactly 20 leaves.
const kDailyLeafGoal = 20;

/// Base loading time once the pet leaves on an adventure.
const kAdventureDuration = Duration(hours: 8);

/// Every this-many leaves earned while walking shaves [kReductionPerStep] off
/// the remaining adventure time (supplementary actions bring the pet home
/// sooner).
const kStrikesPerReduction = 10;
const kReductionPerStep = Duration(minutes: 3);

/// Adventures required to CLEAR [level] (1-based): triangular c(L)=L(L+1)/2 →
/// 1, 3, 6, 10… — each level costs one more adventure than the last.
int _adventuresToClear(int level) => level * (level + 1) ~/ 2;

/// Cumulative adventures needed to REACH [level] (sum of every prior level's
/// clear-cost): L1:0, L2:1, L3:4, L4:10, L5:20…
int _cumulativeToReach(int level) {
  var total = 0;
  for (var k = 1; k < level; k++) {
    total += _adventuresToClear(k);
  }
  return total;
}

/// Current level (1-based) for a number of completed [adventures].
int levelForAdventures(int adventures) {
  var level = 1;
  while (_cumulativeToReach(level + 1) <= adventures) {
    level++;
  }
  return level;
}

/// Adventures completed within the current level (progress numerator).
int adventuresIntoCurrentLevel(int adventures) =>
    adventures - _cumulativeToReach(levelForAdventures(adventures));

/// Adventures needed to clear the current level (progress denominator).
int adventuresForNextLevel(int adventures) =>
    _adventuresToClear(levelForAdventures(adventures));

/// Adventure lifecycle phase.
/// - [charging]: strikes accumulate toward the level's goal; once full the UI
///   surfaces a "Start Adventure" button (derived, see [GameProfile.isReady]).
/// - [walking]: the pet is away; strikes now count up to shorten the timer.
enum AdventurePhase { charging, walking }

/// Per-user gamification state (coins + adventure), persisted at
/// `users/{uid}/meta/game`. Equatable so cubit emits are deduped.
class GameProfile extends Equatable {
  /// Compounding coin total (spendable in a future shop).
  final int coins;

  /// Strike count. Meaning depends on [phase]:
  /// - charging: 0..[strikeGoal] (fills the adventure bar).
  /// - walking: counts up from 0, driving the timer reductions.
  final int strikes;

  /// Current level (1-based). Derived from [adventures] via
  /// [levelForAdventures] — it now takes several adventures to advance.
  final int level;

  final AdventurePhase phase;

  /// Walking window, epoch millis. Null while charging.
  final int? adventureStartMs;
  final int? adventureEndMs;

  /// Ids of earned wisdom trophies (append-only; length == adventures done).
  final List<String> trophies;

  /// Total adventures completed (the level-progression currency).
  final int adventures;

  /// Persisted hearts (health): decays one per [kHeartDecayInterval], restored
  /// [kHeartRestorePerAction] per completed action, capped at [kHeartMax].
  final int hearts;

  /// Decay anchor for [hearts], epoch millis. Null on legacy docs.
  final int? heartsUpdatedAt;

  /// Moment the hearts last hit zero, epoch millis. Bounds the streak run
  /// (activities before it don't count). Null while hearts have never died.
  final int? streakAnchorMs;

  const GameProfile({
    this.coins = 0,
    this.strikes = 0,
    this.level = 1,
    this.phase = AdventurePhase.charging,
    this.adventureStartMs,
    this.adventureEndMs,
    this.trophies = const [],
    this.adventures = 0,
    this.hearts = kHeartMax,
    this.heartsUpdatedAt,
    this.streakAnchorMs,
  });

  /// Leaves required to send the pet on an adventure (fixed daily goal).
  int get strikeGoal => kDailyLeafGoal;

  /// True while charging and the bar is full — ready to start an adventure.
  bool get isReady => phase == AdventurePhase.charging && strikes >= strikeGoal;

  bool get isWalking => phase == AdventurePhase.walking;

  factory GameProfile.fromMap(Map<String, dynamic> data) {
    // Parse trophies first so `adventures` can fall back to its length.
    final trophies = List<String>.from(data['trophies'] as List? ?? const []);
    return GameProfile(
      coins: (data['coins'] as int?) ?? 0,
      strikes: (data['strikes'] as int?) ?? 0,
      level: (data['level'] as int?) ?? 1,
      phase: (data['phase'] as String?) == 'walking'
          ? AdventurePhase.walking
          : AdventurePhase.charging,
      adventureStartMs: data['adventureStartMs'] as int?,
      adventureEndMs: data['adventureEndMs'] as int?,
      trophies: trophies,
      adventures: (data['adventures'] as int?) ?? trophies.length,
      hearts: (data['hearts'] as int?) ?? kHeartMax,
      heartsUpdatedAt: data['heartsUpdatedAt'] as int?,
      streakAnchorMs: data['streakAnchorMs'] as int?,
    );
  }

  Map<String, dynamic> toMap() => {
    'coins': coins,
    'strikes': strikes,
    'level': level,
    'phase': phase == AdventurePhase.walking ? 'walking' : 'charging',
    'adventureStartMs': adventureStartMs,
    'adventureEndMs': adventureEndMs,
    'trophies': trophies,
    'adventures': adventures,
    'hearts': hearts,
    'heartsUpdatedAt': heartsUpdatedAt,
    'streakAnchorMs': streakAnchorMs,
  };

  GameProfile copyWith({
    int? coins,
    int? strikes,
    int? level,
    AdventurePhase? phase,
    int? adventureStartMs,
    int? adventureEndMs,
    List<String>? trophies,
    int? adventures,
    int? hearts,
    int? heartsUpdatedAt,
    int? streakAnchorMs,
    bool clearWindow = false,
  }) => GameProfile(
    coins: coins ?? this.coins,
    strikes: strikes ?? this.strikes,
    level: level ?? this.level,
    phase: phase ?? this.phase,
    adventureStartMs: clearWindow ? null : (adventureStartMs ?? this.adventureStartMs),
    adventureEndMs: clearWindow ? null : (adventureEndMs ?? this.adventureEndMs),
    trophies: trophies ?? this.trophies,
    adventures: adventures ?? this.adventures,
    hearts: hearts ?? this.hearts,
    heartsUpdatedAt: heartsUpdatedAt ?? this.heartsUpdatedAt,
    streakAnchorMs: streakAnchorMs ?? this.streakAnchorMs,
  );

  @override
  List<Object?> get props => [
    coins,
    strikes,
    level,
    phase,
    adventureStartMs,
    adventureEndMs,
    trophies,
    adventures,
    hearts,
    heartsUpdatedAt,
    streakAnchorMs,
  ];
}
