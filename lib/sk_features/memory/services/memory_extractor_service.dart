import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../chat/services/chat_firestore_service.dart';
import '../../chat/services/chat_message.dart';
import '../../chat/services/gemini_service.dart';
import '../models/life_event.dart';
import 'memory_firestore_service.dart';

/// Orchestrates a single memory extraction for a finished conversation:
/// loads transcript + existing memory, asks Gemini, writes the results.
///
/// Best-effort. All errors are swallowed and logged — never throw upward so
/// the chat experience is not affected by extraction failures.
class MemoryExtractorService {
  MemoryExtractorService({
    ChatRepository? chatRepo,
    MemoryRepository? memoryRepo,
    GeminiClient? gemini,
    Uuid? uuid,
  })  : _chatRepo = chatRepo ?? ChatFirestoreService.instance,
        _memoryRepo = memoryRepo ?? MemoryFirestoreService.instance,
        _gemini = gemini ?? GeminiService.instance,
        _uuid = uuid ?? const Uuid();

  static final MemoryExtractorService instance = MemoryExtractorService();

  final ChatRepository _chatRepo;
  final MemoryRepository _memoryRepo;
  final GeminiClient _gemini;
  final Uuid _uuid;

  /// Extracts memory from [conversationId] and writes results to Firestore.
  /// Returns true if extraction ran end-to-end successfully.
  Future<bool> extractFromConversation(String conversationId) async {
    try {
      final messages = await _chatRepo.getMessages(conversationId);
      final hasUserMsg = messages.any((m) => m.role == ChatRole.user);
      if (!hasUserMsg) {
        debugPrint(
          '[MemoryExtractor] skip $conversationId: no user messages',
        );
        return false;
      }

      final profile = await _memoryRepo.getProfile();
      final existingEvents =
          await _memoryRepo.getLifeEventsForConversation(conversationId);
      final existingTitles =
          existingEvents.map((e) => e.title.toLowerCase()).toList();

      final result = await _gemini.extractMemory(
        history: messages,
        existingFacts: profile.facts,
        existingEventTitles: existingEvents.map((e) => e.title).toList(),
      );

      // Filter out events whose title roughly matches an already-stored one
      // for this conversation.
      final newEvents = <LifeEvent>[];
      final now = DateTime.now();
      for (final e in result.newEvents) {
        if (existingTitles.contains(e.title.toLowerCase())) continue;
        newEvents.add(LifeEvent(
          id: _uuid.v4(),
          title: e.title,
          description: e.description,
          occurredAt: e.occurredAt,
          sourceConversationId: conversationId,
          createdAt: now,
        ));
      }

      if (result.factUpdates.isNotEmpty) {
        await _memoryRepo.mergeProfileFacts(result.factUpdates);
      }
      if (newEvents.isNotEmpty) {
        await _memoryRepo.appendLifeEvents(newEvents);
      }
      await _chatRepo.updateConversation(
        conversationId,
        summary: result.summary,
        summaryAt: now,
        memoryExtracted: true,
      );

      debugPrint(
        '[MemoryExtractor] $conversationId: '
        '${result.factUpdates.length} facts, '
        '${newEvents.length} events, '
        'summary=${result.summary.isNotEmpty}',
      );
      return true;
    } catch (e, st) {
      debugPrint('[MemoryExtractor] extract failed for $conversationId: $e\n$st');
      return false;
    }
  }
}
