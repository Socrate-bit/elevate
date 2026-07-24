import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../chat/services/chat_conversation.dart';
import '../../chat/services/chat_firestore_service.dart';
import '../models/journal_insight.dart';
import 'journal_state.dart';

/// Aggregates every generated insight across all of the user's conversations
/// into a single newest-first list for the Journal.
///
/// Insights live embedded on individual messages
/// (`users/{uid}/conversations/{cid}/messages/{mid}`), so there is no direct
/// query for "all insights". We instead watch the conversations stream and fan
/// out to fetch messages — but only for conversations that are new or whose
/// [ChatConversation.lastMessageAt] advanced since we last read them, keeping
/// Firestore reads bounded while staying reactive (generating an insight bumps
/// the conversation timestamp).
class JournalCubit extends Cubit<JournalState> {
  JournalCubit({ChatRepository? repository})
    : _repo = repository ?? ChatFirestoreService.instance,
      super(const JournalState());

  final ChatRepository _repo;
  StreamSubscription? _sub;

  /// Last-seen `lastMessageAt` (ms) per conversation — drives selective refetch.
  final Map<String, int> _seenLastMs = {};

  /// Cached insights per conversation, rebuilt only when that conversation changed.
  final Map<String, List<JournalInsight>> _byConversation = {};

  /// Subscribes to the conversations stream and keeps the insight list in sync.
  void start() {
    _sub?.cancel();
    _sub = _repo.watchConversations().listen(
      _onConversations,
      onError: (e) {
        debugPrint('[JournalCubit] watchConversations error: $e');
        emit(state.copyWith(isLoading: false));
      },
    );
  }

  Future<void> _onConversations(List<ChatConversation> conversations) async {
    final currentIds = conversations.map((c) => c.id).toSet();

    // Drop conversations that no longer exist.
    _seenLastMs.keys
        .where((id) => !currentIds.contains(id))
        .toList()
        .forEach((id) {
          _seenLastMs.remove(id);
          _byConversation.remove(id);
        });

    // Refetch only new or updated conversations.
    for (final c in conversations) {
      final lastMs = c.lastMessageAt.millisecondsSinceEpoch;
      if (_seenLastMs[c.id] == lastMs) continue;
      try {
        final messages = await _repo.getMessages(c.id);
        // Mark seen only after a successful fetch so a transient error retries.
        _seenLastMs[c.id] = lastMs;
        _byConversation[c.id] = messages
            .where((m) => m.insight != null)
            .map(
              (m) => JournalInsight(
                insight: m.insight!,
                createdAt: m.createdAt,
                conversationId: c.id,
              ),
            )
            .toList();
      } catch (e) {
        debugPrint('[JournalCubit] getMessages(${c.id}) error: $e');
      }
    }

    if (isClosed) return;
    final all = _byConversation.values.expand((e) => e).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    debugPrint('[JournalCubit] loaded ${all.length} insights');
    emit(state.copyWith(insights: all, isLoading: false));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
