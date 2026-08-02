// Heart mechanic tuning + pure helpers.
//
// Hearts are the pet's "health": they decay one per [kHeartDecayInterval] and a
// completed action restores [kHeartRestorePerAction] (capped at [kHeartMax]).
// Unlike the old derived model, hearts are PERSISTED (on the game profile) and
// settled on read from a decay anchor — see [HeartService.settle].

/// Maximum number of hearts (full health).
const kHeartMax = 4;

/// One heart is lost per this much inactivity.
const kHeartDecayInterval = Duration(hours: 12);

/// Hearts restored by a single completed action.
const kHeartRestorePerAction = 2;

/// Pet mood animations, keyed by remaining hearts.
const _petSad = 'assets/home/sad_pet.gif';
const _petBored = 'assets/home/bored_pet.gif';
const _petNormal = 'assets/home/pet_rest_animation.gif';

/// Result of settling hearts: the current [hearts] plus the (possibly advanced)
/// decay [anchorMs].
class HeartSettle {
  final int hearts;
  final int anchorMs;
  const HeartSettle(this.hearts, this.anchorMs);
}

class HeartService {
  /// Applies whole decay steps elapsed since [anchorMs], preserving the
  /// sub-step remainder (the anchor advances by the consumed steps). On hitting
  /// zero the countdown is meaningless, so the anchor re-bases to [nowMs]. A
  /// null anchor (legacy doc) starts fresh — no decay is applied this read.
  static HeartSettle settle(int hearts, int? anchorMs, int nowMs) {
    if (hearts <= 0) return HeartSettle(0, anchorMs ?? nowMs);
    final anchor = anchorMs ?? nowMs;
    final elapsed = nowMs - anchor;
    final stepMs = kHeartDecayInterval.inMilliseconds;
    final steps = elapsed <= 0 ? 0 : elapsed ~/ stepMs;
    if (steps <= 0) return HeartSettle(hearts, anchor);
    final newHearts = (hearts - steps).clamp(0, kHeartMax);
    final newAnchor = newHearts <= 0 ? nowMs : anchor + steps * stepMs;
    return HeartSettle(newHearts, newAnchor);
  }

  /// A completed action: settle decay, then add [kHeartRestorePerAction]
  /// (capped at [kHeartMax]) and re-base the decay window to [nowMs].
  static HeartSettle restore(int hearts, int? anchorMs, int nowMs) {
    final settled = settle(hearts, anchorMs, nowMs);
    final restored =
        (settled.hearts + kHeartRestorePerAction).clamp(0, kHeartMax);
    return HeartSettle(restored, nowMs);
  }

  /// Pet animation asset for a given heart count.
  static String petAssetForHearts(int hearts) {
    if (hearts <= 0) return _petSad;
    if (hearts <= 2) return _petBored;
    return _petNormal;
  }
}
