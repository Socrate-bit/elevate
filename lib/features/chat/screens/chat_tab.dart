import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/chat_cubit.dart';
import '../cubit/chat_list_cubit.dart';
import '../cubit/chat_list_state.dart';
import '../widgets/chat_history_sheet.dart';
import 'chat_screen.dart';

/// Bottom-nav tab that hosts the chat experience.
/// Owns the active conversation id so switching chats keeps the bottom bar
/// visible. Picks the most recent conversation on first load, or creates one
/// when the user has none.
class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab>
    with AutomaticKeepAliveClientMixin {
  String? _currentId;
  bool _bootstrapping = false;

  @override
  bool get wantKeepAlive => true;

  /// Picks an active conversation once the list has settled.
  /// No-op if a conversation is already active.
  Future<void> _bootstrap(ChatListState state) async {
    if (_currentId != null || _bootstrapping) return;
    if (state.isLoading) return;
    _bootstrapping = true;
    try {
      if (state.conversations.isNotEmpty) {
        if (!mounted) return;
        setState(() => _currentId = state.conversations.first.id);
      } else {
        final conv =
            await context.read<ChatListCubit>().createConversation();
        if (!mounted) return;
        setState(() => _currentId = conv.id);
      }
    } catch (e) {
      debugPrint('[ChatTab] bootstrap failed: $e');
    } finally {
      _bootstrapping = false;
    }
  }

  Future<void> _openHistory() async {
    final picked = await showChatHistorySheet(context);
    if (!mounted || picked == null) return;
    setState(() => _currentId = picked.id);
  }

  Future<void> _newChat() async {
    try {
      final conv = await context.read<ChatListCubit>().createConversation();
      if (!mounted) return;
      setState(() => _currentId = conv.id);
    } catch (e) {
      debugPrint('[ChatTab] newChat failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<ChatListCubit, ChatListState>(
      listener: (context, state) => _bootstrap(state),
      builder: (context, state) {
        final id = _currentId;
        if (id == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Re-create ChatCubit when the active conversation changes.
        return BlocProvider(
          key: ValueKey(id),
          create: (_) => ChatCubit(conversationId: id),
          child: ChatScreen(
            onOpenHistory: _openHistory,
            onNewChat: _newChat,
          ),
        );
      },
    );
  }
}
