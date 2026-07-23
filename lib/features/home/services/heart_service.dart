import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../auth/auth_service.dart';

/// Heart mechanic tuning + pure helpers.
///
/// Hearts represent the pet's "health": they decay with inactivity and refill
/// when the user completes an activity. They are derived from the timestamp of
/// the last completed activity (no per-heart persistence). The only persisted
/// field is `streakBrokenAt`, written once when the hearts fully deplete.

/// Maximum number of hearts (full health).
const kHeartMax = 4;

/// One heart is lost per this much inactivity since the last activity.
const kHeartDecayInterval = Duration(hours: 8);

/// Pet mood animations, keyed by remaining hearts.
const _petSad = 'assets/home/sad_pet.gif';
const _petBored = 'assets/home/bored_pet.gif';
const _petNormal = 'assets/home/pet_rest_animation.gif';

class HeartService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> get _profileDoc => _db
      .collection('users')
      .doc(AuthService.uid)
      .collection('meta')
      .doc('profile');

  /// Hearts remaining given the last completed activity time. No activity yet
  /// (fresh pet) → full hearts. Clamped to [0, kHeartMax].
  static int computeHearts(DateTime? lastActivityAt, {DateTime? now}) {
    if (lastActivityAt == null) return kHeartMax;
    final elapsed = (now ?? DateTime.now()).difference(lastActivityAt);
    final lost = elapsed.inMinutes ~/ kHeartDecayInterval.inMinutes;
    return (kHeartMax - lost).clamp(0, kHeartMax);
  }

  /// Moment all hearts are depleted (streak-break time), or null if no activity.
  static DateTime? heartsDepletedAt(DateTime? lastActivityAt) {
    if (lastActivityAt == null) return null;
    return lastActivityAt.add(kHeartDecayInterval * kHeartMax);
  }

  /// Pet animation asset for a given heart count.
  static String petAssetForHearts(int hearts) {
    if (hearts <= 0) return _petSad;
    if (hearts <= 2) return _petBored;
    return _petNormal;
  }

  /// Persists the moment the streak was broken by heart depletion. Written once
  /// per depletion (caller guards against redundant writes).
  static Future<void> recordStreakBreak(DateTime at) async {
    try {
      await _profileDoc.set(
        {'streakBrokenAt': at.millisecondsSinceEpoch},
        SetOptions(merge: true),
      );
      debugPrint('[HeartService] Streak broken at $at (hearts depleted)');
    } catch (e) {
      debugPrint('[HeartService] Failed to record streak break: $e');
    }
  }
}
