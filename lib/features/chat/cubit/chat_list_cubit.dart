import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../subscription/services/analytics_service.dart';
import '../services/chat_conversation.dart';
import '../services/chat_firestore_service.dart';
import 'chat_list_state.dart';

/// Owns the live list of conversations and the history search query.
class ChatListCubit extends Cubit<ChatListState> {
  ChatListCubit({ChatRepository? repository, Uuid? uuid})
    : _repo = repository ?? ChatFirestoreService.instance,
      _uuid = uuid ?? const Uuid(),
      super(const ChatListState());

  final ChatRepository _repo;
  final Uuid _uuid;
  StreamSubscription? _sub;

  /// Subscribes to the Firestore conversations stream for the current user.
  /// Call when auth flips to signed-in.
  void start() {
    _sub?.cancel();
    emit(state.copyWith(isLoading: true));
    _sub = _repo.watchConversations().listen(
      (conversations) {
        emit(state.copyWith(conversations: conversations, isLoading: false));
      },
      onError: (e) {
        debugPrint('[ChatListCubit] watchConversations error: $e');
        emit(state.copyWith(isLoading: false));
      },
    );
  }

  /// Cancels the stream and clears local state on sign-out.
  void clear() {
    _sub?.cancel();
    _sub = null;
    emit(const ChatListState());
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  /// Creates a new empty conversation locally and in Firestore.
  /// Title is filled in lazily on the first user message.
  Future<ChatConversation> createConversation() async {
    final now = DateTime.now();
    final conv = ChatConversation(
      id: _uuid.v4(),
      title: '',
      createdAt: now,
      lastMessageAt: now,
    );
    emit(state.copyWith(conversations: [conv, ...state.conversations]));
    try {
      await _repo.saveConversation(conv);
      debugPrint('[ChatListCubit] created conversation ${conv.id}');
      AnalyticsService.capture(AnalyticsService.chatConversationCreated);
    } catch (e) {
      debugPrint('[ChatListCubit] createConversation failed: $e');
      emit(
        state.copyWith(
          conversations: state.conversations
              .where((c) => c.id != conv.id)
              .toList(),
        ),
      );
      rethrow;
    }
    return conv;
  }

  Future<void> deleteConversation(String id) async {
    final previous = state.conversations;
    emit(
      state.copyWith(
        conversations: state.conversations.where((c) => c.id != id).toList(),
      ),
    );
    try {
      await _repo.deleteConversation(id);
      debugPrint('[ChatListCubit] deleted conversation $id');
      AnalyticsService.capture(AnalyticsService.chatConversationDeleted);
    } catch (e) {
      debugPrint('[ChatListCubit] deleteConversation failed: $e');
      emit(state.copyWith(conversations: previous));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
