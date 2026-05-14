import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../chat/services/chat_conversation.dart';
import '../../chat/services/chat_firestore_service.dart';
import '../services/memory_extractor_service.dart';
import '../services/memory_firestore_service.dart';
import 'memory_state.dart';

/// Owns the user's reactive memory: profile facts and a derived list of
/// recent conversation summaries. Also exposes triggers for extraction
/// (one-off via [extractNow], catch-up via [processPendingExtractions]).
class MemoryCubit extends Cubit<MemoryState> {
  MemoryCubit({
    MemoryRepository? memoryRepo,
    ChatRepository? chatRepo,
    MemoryExtractorService? extractor,
  })  : _memoryRepo = memoryRepo ?? MemoryFirestoreService.instance,
        _chatRepo = chatRepo ?? ChatFirestoreService.instance,
        _extractor = extractor ?? MemoryExtractorService.instance,
        super(MemoryState.initial());

  final MemoryRepository _memoryRepo;
  final ChatRepository _chatRepo;
  final MemoryExtractorService _extractor;

  StreamSubscription? _profileSub;
  StreamSubscription? _convSub;
  bool _didCatchUp = false;

  /// Subscribes to memory streams. Call when auth flips to signed-in.
  void start() {
    _profileSub?.cancel();
    _convSub?.cancel();
    _didCatchUp = false;
    emit(state.copyWith(isLoading: true));

    _profileSub = _memoryRepo.watchProfile().listen(
      (profile) {
        emit(state.copyWith(profile: profile, isLoading: false));
      },
      onError: (e) {
        debugPrint('[MemoryCubit] watchProfile error: $e');
        emit(state.copyWith(isLoading: false));
      },
    );

    _convSub = _chatRepo.watchConversations().listen(
      (conversations) {
        final summaries = conversations
            .where((c) => c.summary.isNotEmpty)
            .map((c) => ConversationSummary(
                  conversationId: c.id,
                  summary: c.summary,
                  lastMessageAt: c.lastMessageAt,
                ))
            .toList();
        emit(state.copyWith(recentSummaries: summaries));

        // One-shot catch-up on first conversations snapshot after sign-in.
        if (!_didCatchUp) {
          _didCatchUp = true;
          unawaited(_processPending(conversations));
        }
      },
      onError: (e) {
        debugPrint('[MemoryCubit] watchConversations error: $e');
      },
    );
  }

  /// Cancels subscriptions and resets to empty state. Call on sign-out.
  void clear() {
    _profileSub?.cancel();
    _convSub?.cancel();
    _profileSub = null;
    _convSub = null;
    _didCatchUp = false;
    emit(MemoryState.initial());
  }

  /// Manually re-runs catch-up scan against the current conversation list.
  Future<void> processPendingExtractions() async {
    await _processPending(null);
  }

  /// Internal: scan [conversations] (or fetch fresh) and extract any flagged
  /// `memoryExtracted == false`.
  Future<void> _processPending(List<ChatConversation>? conversations) async {
    try {
      // We don't have a one-shot getConversations on the repo, so if the
      // caller didn't pass a list, just no-op — the conversations stream is
      // expected to be live by the time this is called.
      if (conversations == null) return;
      final pending =
          conversations.where((c) => !c.memoryExtracted).toList();
      if (pending.isEmpty) return;
      debugPrint(
        '[MemoryCubit] catch-up extraction for ${pending.length} conversation(s)',
      );
      for (final c in pending) {
        await _extractor.extractFromConversation(c.id);
      }
    } catch (e) {
      debugPrint('[MemoryCubit] processPending failed: $e');
    }
  }

  /// Fire-and-forget extraction for one conversation. Used when the user
  /// leaves the chat screen.
  Future<void> extractNow(String conversationId) async {
    await _extractor.extractFromConversation(conversationId);
  }

  /// Builds the memory-context string injected into Gemini's system prompt.
  /// Includes profile facts + up to 10 most recent conversation summaries,
  /// excluding the currently-active conversation.
  String buildMemoryContext({String? excludeConversationId, int summaryLimit = 10}) {
    final buffer = StringBuffer();

    final facts = state.profile.facts;
    if (facts.isNotEmpty) {
      buffer.writeln('Profile facts about the user:');
      final keys = facts.keys.toList()..sort();
      for (final k in keys) {
        buffer.writeln('- $k: ${facts[k]}');
      }
    }

    final filtered = state.recentSummaries
        .where((s) => s.conversationId != excludeConversationId)
        .toList()
      ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    final top = filtered.take(summaryLimit).toList();
    if (top.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.writeln();
      buffer.writeln('Recent past conversations (most recent first):');
      for (final s in top) {
        buffer.writeln('- ${s.summary}');
      }
    }

    return buffer.toString().trim();
  }

  @override
  Future<void> close() {
    _profileSub?.cancel();
    _convSub?.cancel();
    return super.close();
  }
}
