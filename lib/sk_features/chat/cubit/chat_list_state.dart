import 'package:equatable/equatable.dart';

import '../services/chat_conversation.dart';

/// State for [ChatListCubit]: the user's conversation history and search query.
class ChatListState extends Equatable {
  final List<ChatConversation> conversations;
  final String searchQuery;
  final bool isLoading;

  const ChatListState({
    this.conversations = const [],
    this.searchQuery = '',
    this.isLoading = false,
  });

  ChatListState copyWith({
    List<ChatConversation>? conversations,
    String? searchQuery,
    bool? isLoading,
  }) => ChatListState(
    conversations: conversations ?? this.conversations,
    searchQuery: searchQuery ?? this.searchQuery,
    isLoading: isLoading ?? this.isLoading,
  );

  /// Conversations filtered by [searchQuery] against title only.
  List<ChatConversation> get filtered {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return conversations;
    return conversations
        .where((c) => c.title.toLowerCase().contains(q))
        .toList();
  }

  @override
  List<Object?> get props => [conversations, searchQuery, isLoading];
}
