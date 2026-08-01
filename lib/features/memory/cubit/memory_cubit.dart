import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/memory_builder_service.dart';
import '../services/memory_firestore_service.dart';
import 'memory_state.dart';

/// Owns the user's reactive memory (facts, life events, rolling summaries, life
/// rating, and insight progress) and exposes the per-exchange memory builder.
class MemoryCubit extends Cubit<MemoryState> {
  MemoryCubit({MemoryRepository? memoryRepo, MemoryBuilderService? builder})
    : _memoryRepo = memoryRepo ?? MemoryFirestoreService.instance,
      _builder = builder ?? MemoryBuilderService.instance,
      super(MemoryState.initial());

  final MemoryRepository _memoryRepo;
  final MemoryBuilderService _builder;

  final List<StreamSubscription> _subs = [];

  /// Guards the one-time onboarding → life-rating seed so it runs at most once
  /// per session even as the rating stream re-emits.
  bool _seedAttempted = false;

  /// Subscribes to all memory streams. Call when auth flips to signed-in.
  void start() {
    _cancelSubs();
    _seedAttempted = false;
    emit(state.copyWith(isLoading: true));

    _subs.add(
      _memoryRepo.watchProfile().listen(
        (profile) => emit(state.copyWith(profile: profile, isLoading: false)),
        onError: (e) {
          debugPrint('[MemoryCubit] watchProfile error: $e');
          emit(state.copyWith(isLoading: false));
        },
      ),
    );

    _subs.add(
      _memoryRepo.watchEvents().listen(
        (events) => emit(state.copyWith(events: events)),
        onError: (e) => debugPrint('[MemoryCubit] watchEvents error: $e'),
      ),
    );

    _subs.add(
      _memoryRepo.watchSummaries(limit: 20).listen(
        (summaries) => emit(state.copyWith(summaries: summaries)),
        onError: (e) => debugPrint('[MemoryCubit] watchSummaries error: $e'),
      ),
    );

    _subs.add(
      _memoryRepo.watchLifeRating().listen(
        (rating) {
          emit(state.copyWith(lifeRating: rating));
          if (!rating.seeded && !_seedAttempted) {
            _seedAttempted = true;
            unawaited(_seedLifeRatingFromOnboarding());
          }
        },
        onError: (e) => debugPrint('[MemoryCubit] watchLifeRating error: $e'),
      ),
    );

    _subs.add(
      _memoryRepo.watchBuilderState().listen(
        (bs) => emit(
          state.copyWith(
            insightProgress: bs.insightProgress,
            insightBoundaryMs: bs.insightBoundaryMs,
          ),
        ),
        onError: (e) => debugPrint('[MemoryCubit] watchBuilderState error: $e'),
      ),
    );
  }

  /// Cancels subscriptions and resets to empty state. Call on sign-out.
  void clear() {
    _cancelSubs();
    _seedAttempted = false;
    emit(MemoryState.initial());
  }

  /// Copies the onboarding wheel-of-life ratings into memory the first time we
  /// see an unseeded rating doc. Idempotent — `seedLifeRating` sets `seeded`.
  Future<void> _seedLifeRatingFromOnboarding() async {
    try {
      final ratings = await _memoryRepo.getOnboardingLifeRatings();
      if (ratings.isEmpty) {
        debugPrint('[MemoryCubit] no onboarding ratings to seed');
        return;
      }
      await _memoryRepo.seedLifeRating(ratings);
      debugPrint('[MemoryCubit] seeded life rating from onboarding');
    } catch (e) {
      debugPrint('[MemoryCubit] life-rating seed failed: $e');
    }
  }

  /// Runs one background memory-builder pass for [conversationId]. Called by
  /// ChatCubit after each assistant reply.
  Future<void> analyze(String conversationId) =>
      _builder.analyzeExchange(conversationId);

  /// Records that an insight was generated at [boundaryMs], resetting the
  /// insight progress so the ring restarts from empty.
  Future<void> markInsight(int boundaryMs) =>
      _memoryRepo.writeInsightBoundary(boundaryMs);

  void _cancelSubs() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
  }

  @override
  Future<void> close() {
    _cancelSubs();
    return super.close();
  }
}
