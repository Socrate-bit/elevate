import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../auth/auth_service.dart';
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

  /// Awards a completion: `+coins` and `+1 strike`. While walking, every
  /// [kStrikesPerReduction] strikes shortens the timer by [kReductionPerStep]
  /// (floored at [now]); in debug builds any new strike finishes it instantly.
  static Future<void> awardCompletion({
    required int coins,
    required DateTime now,
  }) async {
    try {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(_gameDoc);
        final profile = snap.exists && snap.data() != null
            ? GameProfile.fromMap(snap.data()!)
            : const GameProfile();

        final newStrikes = profile.strikes + 1;
        var endMs = profile.adventureEndMs;

        if (profile.phase == AdventurePhase.walking && endMs != null) {
          if (kDebugMode) {
            // Debug shortcut: any new strike finishes the adventure.
            endMs = now.millisecondsSinceEpoch;
          } else if (newStrikes % kStrikesPerReduction == 0) {
            final reduced = endMs - kReductionPerStep.inMilliseconds;
            endMs = reduced < now.millisecondsSinceEpoch
                ? now.millisecondsSinceEpoch
                : reduced;
          }
        }

        final updated = profile.copyWith(
          coins: profile.coins + coins,
          strikes: newStrikes,
          adventureEndMs: endMs,
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
  /// `-1 strike` while charging (walking strikes are left untouched).
  static Future<void> removeCompletion({required int coins}) async {
    try {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(_gameDoc);
        if (!snap.exists || snap.data() == null) return;
        final profile = GameProfile.fromMap(snap.data()!);

        final newCoins = (profile.coins - coins).clamp(0, 1 << 31).toInt();
        final newStrikes = profile.phase == AdventurePhase.charging
            ? (profile.strikes - 1).clamp(0, 1 << 31).toInt()
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

  /// Claims the reward: records the earned trophy [wisdomId] and resets to a
  /// fresh charging bar.
  static Future<void> discover(String wisdomId) async {
    try {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(_gameDoc);
        final profile = snap.exists && snap.data() != null
            ? GameProfile.fromMap(snap.data()!)
            : const GameProfile();

        tx.set(
          _gameDoc,
          profile
              .copyWith(
                phase: AdventurePhase.charging,
                strikes: 0,
                trophies: [...profile.trophies, wisdomId],
                clearWindow: true,
              )
              .toMap(),
        );
      });
      debugPrint('[AdventureService] adventure discovered: $wisdomId');
      AnalyticsService.capture(AnalyticsService.adventureCompleted, {
        'wisdom_id': wisdomId,
      });
    } catch (e) {
      debugPrint('[AdventureService] discover failed: $e');
      rethrow;
    }
  }
}
