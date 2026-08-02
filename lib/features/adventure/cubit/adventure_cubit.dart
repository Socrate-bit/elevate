import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/game_profile.dart';
import '../services/adventure_service.dart';
import 'adventure_state.dart';

/// Owns the coin / strike / adventure state. Streams the game profile from
/// Firestore and drives a ticking clock while the pet is on an adventure so the
/// loading bar advances and completes on its own.
class AdventureCubit extends Cubit<AdventureState> {
  AdventureCubit()
    : super(AdventureState(nowMs: DateTime.now().millisecondsSinceEpoch)) {
    _subscribe();
    // Slow always-on tick: re-renders settled hearts and records the
    // zero-crossing (streak reset) even when the pet isn't walking.
    _heartTicker = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _settleHearts(),
    );
  }

  StreamSubscription<GameProfile>? _sub;
  Timer? _ticker;
  Timer? _heartTicker;

  void _subscribe() {
    _sub = AdventureService.watchProfile().listen((profile) {
      if (isClosed) return;
      emit(
        state.copyWith(
          profile: profile,
          nowMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      _syncTicker();
      // Handle a cold-start crossing (hearts died while the app was closed).
      _settleHearts();
    });
  }

  /// Refreshes [AdventureState.nowMs] so settled hearts re-render, and persists
  /// the streak reset if hearts have just hit zero (guarded / idempotent).
  void _settleHearts() {
    if (isClosed) return;
    emit(state.copyWith(nowMs: DateTime.now().millisecondsSinceEpoch));
    AdventureService.settleHeartsToZero(DateTime.now());
  }

  /// Runs a 1s clock only while walking (and not yet arrived) so the bar and
  /// the seconds countdown advance; stops it otherwise to save cycles.
  void _syncTicker() {
    final shouldTick = state.isWalking && !state.isArrived;
    if (shouldTick && _ticker == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (isClosed) return;
        emit(state.copyWith(nowMs: DateTime.now().millisecondsSinceEpoch));
        if (state.isArrived) _syncTicker();
      });
    } else if (!shouldTick && _ticker != null) {
      _ticker!.cancel();
      _ticker = null;
    }
  }

  /// Completing a task: award coins + strikes (both == the task's points),
  /// then signal the confetti listener.
  Future<void> awardForCompletion(int xp) async {
    try {
      await AdventureService.awardCompletion(
        coins: xp,
        strikes: xp,
        now: DateTime.now(),
      );
      emit(state.copyWith(rewardNonce: state.rewardNonce + 1));
    } catch (e) {
      debugPrint('[AdventureCubit] awardForCompletion failed: $e');
    }
  }

  /// Un-checking a task: reverse the coins + strikes it granted.
  Future<void> removeForCompletion(int xp) async {
    try {
      await AdventureService.removeCompletion(coins: xp, strikes: xp);
    } catch (e) {
      debugPrint('[AdventureCubit] removeForCompletion failed: $e');
    }
  }

  /// Sends the pet off on the adventure (only fires when the bar is full).
  Future<void> startAdventure() async {
    try {
      await AdventureService.startAdventure(DateTime.now());
    } catch (e) {
      debugPrint('[AdventureCubit] startAdventure failed: $e');
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _ticker?.cancel();
    _heartTicker?.cancel();
    return super.close();
  }
}
