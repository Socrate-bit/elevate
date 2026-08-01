import 'package:flutter/foundation.dart';

import '../../chat/services/chat_firestore_service.dart';
import '../../chat/services/gemini_service.dart';
import 'memory_firestore_service.dart';

/// Runs one background memory-analysis pass per chat exchange: reviews the
/// messages newer than the stored watermark, asks Gemini for fact/event/
/// summary/life-rating ops + insight progress, and applies them.
///
/// Best-effort — all errors are swallowed and logged so the chat is never
/// affected by a builder failure.
class MemoryBuilderService {
  MemoryBuilderService({
    ChatRepository? chatRepo,
    MemoryRepository? memoryRepo,
    GeminiClient? gemini,
  }) : _chatRepo = chatRepo ?? ChatFirestoreService.instance,
       _memoryRepo = memoryRepo ?? MemoryFirestoreService.instance,
       _gemini = gemini ?? GeminiService.instance;

  static final MemoryBuilderService instance = MemoryBuilderService();

  final ChatRepository _chatRepo;
  final MemoryRepository _memoryRepo;
  final GeminiClient _gemini;

  /// Single ongoing conversation → one guard flag is enough to prevent
  /// overlapping passes (a slow pass still running when the next reply lands).
  bool _inFlight = false;

  Future<void> analyzeExchange(String conversationId) async {
    if (_inFlight) return;
    _inFlight = true;
    try {
      final messages = await _chatRepo.getMessages(conversationId);
      if (messages.isEmpty) return;

      final builderState = await _memoryRepo.getBuilderState();
      final lastMs = messages.last.createdAt.millisecondsSinceEpoch;
      if (lastMs <= builderState.analyzedUpToMs) {
        return; // nothing new since the last pass
      }

      final window = GeminiService.lastActiveDaysWindow(messages);
      final profile = await _memoryRepo.getProfile();
      final events = await _memoryRepo.getEvents();
      final lifeRating = await _memoryRepo.getLifeRating();
      final summaries = await _memoryRepo.getRecentSummaries(limit: 5);

      final analysis = await _gemini.analyze(
        windowMessages: window,
        facts: profile.facts,
        events: events,
        lifeRating: lifeRating,
        recentSummaries: summaries,
      );

      if (analysis.factUpserts.isNotEmpty) {
        await _memoryRepo.upsertFacts(analysis.factUpserts);
      }
      if (analysis.factDeletes.isNotEmpty) {
        await _memoryRepo.deleteFacts(analysis.factDeletes);
      }
      if (analysis.eventOps.isNotEmpty) {
        await _memoryRepo.applyEventOps(analysis.eventOps);
      }
      if (analysis.summaryOps.isNotEmpty) {
        await _memoryRepo.applySummaryOps(analysis.summaryOps);
      }
      if (analysis.lifeRatingUpdate != null) {
        await _memoryRepo.updateLifeRating(analysis.lifeRatingUpdate!);
      }

      // Advance the watermark monotonically; carry the new progress if the pass
      // produced one, else leave the previous value.
      final watermark = lastMs > builderState.analyzedUpToMs
          ? lastMs
          : builderState.analyzedUpToMs;
      await _memoryRepo.writeWatermark(watermark, analysis.insightProgress);

      debugPrint(
        '[MemoryBuilder] $conversationId: '
        '${analysis.factUpserts.length} fact upserts, '
        '${analysis.factDeletes.length} deletes, '
        '${analysis.eventOps.length} event ops, '
        '${analysis.summaryOps.length} summary ops, '
        'rating=${analysis.lifeRatingUpdate != null}, '
        'progress=${analysis.insightProgress}',
      );
    } catch (e, st) {
      debugPrint('[MemoryBuilder] analyze failed for $conversationId: $e\n$st');
    } finally {
      _inFlight = false;
    }
  }
}
