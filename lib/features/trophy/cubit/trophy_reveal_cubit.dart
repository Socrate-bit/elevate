import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../adventure/services/adventure_service.dart';
import '../../chat/services/gemini_service.dart';
import '../../routines/models/routine_palette.dart';
import '../../subscription/services/analytics_service.dart';
import '../data/trophy_badges.dart';
import '../models/trophy.dart';
import '../services/trophy_service.dart';
import 'trophy_reveal_state.dart';

/// Orchestrates the single reward reveal shown when an adventure ends:
/// gather recent-conversation context + already-earned citations, ask Gemini
/// for a fresh real citation (fall back to a curated one on failure), persist
/// the trophy, reset the adventure, and surface the trophy so the UI can
/// burst it in.
class TrophyRevealCubit extends Cubit<TrophyRevealState> {
  TrophyRevealCubit({GeminiClient? gemini})
    : _gemini = gemini ?? GeminiService.instance,
      super(const TrophyRevealState());

  final GeminiClient _gemini;

  Future<void> reveal() async {
    try {
      final context = await TrophyService.recentContext();
      final earned = await TrophyService.getTrophies();
      final avoid = earned.map((t) => '${t.quote} — ${t.author}').toList();
      final earnedKeys = avoid.toSet();

      final generated = await _gemini.generateCitation(
        context: context,
        avoid: avoid,
        allowedIcons: kTrophyIconKeys,
        allowedColors: kRoutineColors.keys.toList(),
      );

      final id = TrophyService.newId();
      final now = DateTime.now().millisecondsSinceEpoch;
      final trophy = generated != null
          ? Trophy(
              id: id,
              title: generated.title,
              quote: generated.quote,
              author: generated.author,
              source: generated.source,
              iconKey: isTrophyIconKey(generated.iconKey)
                  ? generated.iconKey
                  : kDefaultTrophyIconKey,
              colorKey: isTrophyColorKey(generated.colorKey)
                  ? generated.colorKey
                  : kDefaultRoutineColorKey,
              conversationId: null,
              createdAtMs: now,
            )
          : _fallbackTrophy(id, now, earnedKeys);

      await TrophyService.add(trophy);
      await AdventureService.completeAdventure(trophy.id);
      AnalyticsService.capture(AnalyticsService.trophyEarned, {
        'trophy_id': trophy.id,
        'author': trophy.author,
        'generated': (generated != null).toString(),
      });

      if (isClosed) return;
      emit(state.copyWith(phase: TrophyRevealPhase.revealed, trophy: trophy));
    } catch (e) {
      // Even on unexpected failure, still award a fallback trophy so the user
      // never taps "Discover" and gets nothing.
      debugPrint('[TrophyRevealCubit] reveal failed: $e');
      await _awardFallback();
    }
  }

  Future<void> _awardFallback() async {
    try {
      final id = TrophyService.newId();
      final now = DateTime.now().millisecondsSinceEpoch;
      final trophy = _fallbackTrophy(id, now, const {});
      await TrophyService.add(trophy);
      await AdventureService.completeAdventure(trophy.id);
      if (isClosed) return;
      emit(state.copyWith(phase: TrophyRevealPhase.revealed, trophy: trophy));
    } catch (e) {
      debugPrint('[TrophyRevealCubit] fallback failed: $e');
    }
  }

  Trophy _fallbackTrophy(String id, int nowMs, Set<String> earnedKeys) {
    final seed = pickFallbackCitation(earnedKeys);
    return Trophy(
      id: id,
      quote: seed.quote,
      author: seed.author,
      source: seed.source,
      iconKey: seed.iconKey,
      colorKey: seed.colorKey,
      conversationId: null,
      createdAtMs: nowMs,
    );
  }
}
