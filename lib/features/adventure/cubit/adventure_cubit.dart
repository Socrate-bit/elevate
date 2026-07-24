import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/wisdom_trophies.dart';
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
  }

  StreamSubscription<GameProfile>? _sub;
  Timer? _ticker;

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
    });
  }

  /// Runs a ~30s clock only while walking (and not yet arrived) so the bar
  /// advances; stops it otherwise to save cycles.
  void _syncTicker() {
    final shouldTick = state.isWalking && !state.isArrived;
    if (shouldTick && _ticker == null) {
      _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
        if (isClosed) return;
        emit(state.copyWith(nowMs: DateTime.now().millisecondsSinceEpoch));
        if (state.isArrived) _syncTicker();
      });
    } else if (!shouldTick && _ticker != null) {
      _ticker!.cancel();
      _ticker = null;
    }
  }

  /// Completing a task: award coins (== the task's XP) + a strike, then signal
  /// the confetti listener.
  Future<void> awardForCompletion(int xp) async {
    try {
      await AdventureService.awardCompletion(coins: xp, now: DateTime.now());
      emit(state.copyWith(rewardNonce: state.rewardNonce + 1));
    } catch (e) {
      debugPrint('[AdventureCubit] awardForCompletion failed: $e');
    }
  }

  /// Un-checking a task: reverse the coins + strike it granted.
  Future<void> removeForCompletion(int xp) async {
    try {
      await AdventureService.removeCompletion(coins: xp);
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

  /// Claims the reward and resets the bar. Returns the earned trophy so the UI
  /// can push the success screen; null on failure.
  Future<WisdomTrophy?> discover() async {
    try {
      final trophy = pickRandomWisdom();
      await AdventureService.discover(trophy.id);
      return trophy;
    } catch (e) {
      debugPrint('[AdventureCubit] discover failed: $e');
      return null;
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _ticker?.cancel();
    return super.close();
  }
}
