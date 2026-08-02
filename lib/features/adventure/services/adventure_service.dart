import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../auth/auth_service.dart';
import '../../home/services/heart_service.dart';
import '../../subscription/services/analytics_service.dart';
import '../models/game_profile.dart';

/// Firestore-backed store for the coin / strike / adventure game state.
/// Static; lives at `users/{uid}/meta/game`.
class AdventureService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> get _gameDoc => _db
      .collection('users')
      .doc(AuthService.uid)
      .collection('meta')
      .doc('game');

  static Future<GameProfile> getProfile() async {
    final doc = await _gameDoc.get();
    if (!doc.exists || doc.data() == null) return const GameProfile();
    return GameProfile.fromMap(doc.data()!);
  }

  /// Real-time stream of the user's game profile.
  static Stream<GameProfile> watchProfile() {
    return _gameDoc.snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return const GameProfile();
      return GameProfile.fromMap(doc.data()!);
    });
  }

  /// Awards a completion: `+coins` and `+strikes` (the task's strike value).
  /// While walking, every [kStrikesPerReduction] strikes shortens the timer by
  /// [kReductionPerStep] (floored at [now]); in debug builds any new strike
  /// finishes it instantly.
  static Future<void> awardCompletion({
    required int coins,
    required int strikes,
    required DateTime now,
  }) async {
    try {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(_gameDoc);
        final profile = snap.exists && snap.data() != null
            ? GameProfile.fromMap(snap.data()!)
            : const GameProfile();

        final newStrikes = profile.strikes + strikes;
        var endMs = profile.adventureEndMs;

        if (profile.phase == AdventurePhase.walking && endMs != null) {
          if (kDebugMode) {
            // Debug shortcut: any new strike finishes the adventure.
            endMs = now.millisecondsSinceEpoch;
          } else {
            // Reduce once per reduction threshold crossed by this award.
            final steps = (newStrikes ~/ kStrikesPerReduction) -
                (profile.strikes ~/ kStrikesPerReduction);
            if (steps > 0) {
              final reduced =
                  endMs - steps * kReductionPerStep.inMilliseconds;
              endMs = reduced < now.millisecondsSinceEpoch
                  ? now.millisecondsSinceEpoch
                  : reduced;
            }
          }
        }

        // A completed action also restores hearts (+2, capped).
        final hs = HeartService.restore(
          profile.hearts,
          profile.heartsUpdatedAt,
          now.millisecondsSinceEpoch,
        );

        final updated = profile.copyWith(
          coins: profile.coins + coins,
          strikes: newStrikes,
          adventureEndMs: endMs,
          hearts: hs.hearts,
          heartsUpdatedAt: hs.anchorMs,
        );
        tx.set(_gameDoc, updated.toMap());
      });
      AnalyticsService.capture(AnalyticsService.coinEarned, {'coins': coins});
    } catch (e) {
      debugPrint('[AdventureService] awardCompletion failed: $e');
      rethrow;
    }
  }

  /// Reverses a completion (task un-checked): `-coins` (floored at 0), and
  /// `-strikes` while charging (walking strikes are left untouched).
  static Future<void> removeCompletion({
    required int coins,
    required int strikes,
  }) async {
    try {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(_gameDoc);
        if (!snap.exists || snap.data() == null) return;
        final profile = GameProfile.fromMap(snap.data()!);

        final newCoins = (profile.coins - coins).clamp(0, 1 << 31).toInt();
        final newStrikes = profile.phase == AdventurePhase.charging
            ? (profile.strikes - strikes).clamp(0, 1 << 31).toInt()
            : profile.strikes;

        tx.set(
          _gameDoc,
          profile.copyWith(coins: newCoins, strikes: newStrikes).toMap(),
        );
      });
    } catch (e) {
      debugPrint('[AdventureService] removeCompletion failed: $e');
      rethrow;
    }
  }

  /// Sends the pet on an adventure: consumes the full bar (strikes -> 0) and
  /// opens the [kAdventureDuration] walking window. No-op if not [isReady].
  static Future<void> startAdventure(DateTime now) async {
    try {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(_gameDoc);
        final profile = snap.exists && snap.data() != null
            ? GameProfile.fromMap(snap.data()!)
            : const GameProfile();
        if (!profile.isReady) return;

        final start = now.millisecondsSinceEpoch;
        tx.set(
          _gameDoc,
          profile
              .copyWith(
                phase: AdventurePhase.walking,
                strikes: 0,
                adventureStartMs: start,
                adventureEndMs: start + kAdventureDuration.inMilliseconds,
              )
              .toMap(),
        );
      });
      debugPrint('[AdventureService] adventure started');
      AnalyticsService.capture(AnalyticsService.adventureStarted);
    } catch (e) {
      debugPrint('[AdventureService] startAdventure failed: $e');
      rethrow;
    }
  }

  /// Settles heart decay and, on the zero-crossing, records the loss: pins
  /// [GameProfile.heartsUpdatedAt]/[GameProfile.streakAnchorMs] to the exact
  /// moment hearts died (so the streak run is bounded there) and forfeits any
  /// charging leaves. Writes ONLY when hearts newly reach zero — idempotent and
  /// cheap to call on every tick (mirrors the old `forfeitStrikes` guard).
  static Future<void> settleHeartsToZero(DateTime now) async {
    try {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(_gameDoc);
        if (!snap.exists || snap.data() == null) return;
        final profile = GameProfile.fromMap(snap.data()!);
        if (profile.hearts <= 0) return; // already dead → nothing to record.
        final nowMs = now.millisecondsSinceEpoch;
        final settled = HeartService.settle(
          profile.hearts,
          profile.heartsUpdatedAt,
          nowMs,
        );
        if (settled.hearts > 0) return; // not crossing yet → no write.

        // Exact moment hearts hit zero: anchor + (hearts * decay interval).
        final zeroAt = (profile.heartsUpdatedAt ?? nowMs) +
            profile.hearts * kHeartDecayInterval.inMilliseconds;
        tx.set(
          _gameDoc,
          profile
              .copyWith(
                hearts: 0,
                heartsUpdatedAt: zeroAt,
                streakAnchorMs: zeroAt,
                // Forfeit unspent charging leaves (walking leaves are locked in).
                strikes: profile.phase == AdventurePhase.charging
                    ? 0
                    : profile.strikes,
              )
              .toMap(),
        );
      });
      debugPrint('[AdventureService] hearts depleted → streak reset');
    } catch (e) {
      debugPrint('[AdventureService] settleHeartsToZero failed: $e');
    }
  }

  /// Claims the reward: records the earned trophy [trophyId], increments the
  /// adventure count (which may advance the level once enough adventures are
  /// banked), and resets to a fresh charging bar.
  static Future<void> completeAdventure(String trophyId) async {
    try {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(_gameDoc);
        final profile = snap.exists && snap.data() != null
            ? GameProfile.fromMap(snap.data()!)
            : const GameProfile();

        final newAdventures = profile.adventures + 1;
        tx.set(
          _gameDoc,
          profile
              .copyWith(
                phase: AdventurePhase.charging,
                strikes: 0,
                adventures: newAdventures,
                level: levelForAdventures(newAdventures),
                trophies: [...profile.trophies, trophyId],
                clearWindow: true,
              )
              .toMap(),
        );
      });
      debugPrint('[AdventureService] adventure completed: $trophyId');
      AnalyticsService.capture(AnalyticsService.adventureCompleted, {
        'trophy_id': trophyId,
      });
    } catch (e) {
      debugPrint('[AdventureService] completeAdventure failed: $e');
      rethrow;
    }
  }
}
