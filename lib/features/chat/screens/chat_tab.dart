import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_list_cubit.dart';
import '../widgets/chat_composer.dart';
import '../widgets/chat_history_sheet.dart';
import 'chat_screen.dart';

/// Bottom-nav tab that hosts the chat experience.
///
/// - No conversation is created eagerly — the greeting appears immediately.
/// - A conversation is only created when the user sends the first message.
/// - "New chat" (+ icon) resets to the greeting without touching Firestore.
/// - History (list icon) opens the modal sheet; picking a conversation loads it.
class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> with AutomaticKeepAliveClientMixin {
  /// Non-null once a conversation is active (selected from history or after
  /// the first message creates one).
  String? _currentId;

  /// Text entered in the pre-chat composer that should be sent as soon as the
  /// newly-created conversation's ChatCubit is ready.
  String? _pendingMessage;

  @override
  bool get wantKeepAlive => true;

  Future<void> _openHistory() async {
    final picked = await showChatHistorySheet(context);
    if (!mounted || picked == null) return;
    setState(() {
      _currentId = picked.id;
      _pendingMessage = null;
    });
  }

  /// Resets to the empty greeting without creating anything.
  void _newChat() {
    setState(() {
      _currentId = null;
      _pendingMessage = null;
    });
  }

  /// Called by the pre-chat composer on first send.
  /// Creates the conversation, then hands [text] off to ChatScreen.
  Future<void> _handleFirstSend(String text) async {
    if (text.trim().isEmpty) return;
    try {
      final conv = await context.read<ChatListCubit>().createConversation();
      if (!mounted) return;
      setState(() {
        _currentId = conv.id;
        _pendingMessage = text.trim();
      });
    } catch (e) {
      debugPrint('[ChatTab] createConversation failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final id = _currentId;

    if (id == null) {
      // No active conversation — show the greeting and let the user start typing.
      return _PreChatView(
        onOpenHistory: _openHistory,
        onNewChat: _newChat,
        onSend: _handleFirstSend,
      );
    }

    // Active conversation — re-create ChatCubit when the id changes.
    return BlocProvider(
      key: ValueKey(id),
      create: (_) => ChatCubit(conversationId: id),
      child: ChatScreen(
        onOpenHistory: _openHistory,
        onNewChat: _newChat,
        initialMessage: _pendingMessage,
      ),
    );
  }
}

/// Greeting screen shown before any conversation exists.
/// Looks identical to ChatScreen's empty state with a working composer.
class _PreChatView extends StatefulWidget {
  final VoidCallback onOpenHistory;
  final VoidCallback onNewChat;
  final Future<void> Function(String text) onSend;

  const _PreChatView({
    required this.onOpenHistory,
    required this.onNewChat,
    required this.onSend,
  });

  @override
  State<_PreChatView> createState() => _PreChatViewState();
}

class _PreChatViewState extends State<_PreChatView> {
  final _composer = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _composer.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    await widget.onSend(text);
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final navReserved = MediaQuery.viewPaddingOf(context).bottom + 84.h;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.format_list_bulleted_rounded, size: 22.sp),
          onPressed: withHaptic(widget.onOpenHistory),
        ),
        centerTitle: true,
        title: Text(
          l10n.chatModelName,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: c.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, size: 26.sp),
            tooltip: l10n.chatNewConversation,
            onPressed: widget.onNewChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 36.sp, color: c.primary),
                    SizedBox(height: 16.h),
                    Text(
                      l10n.chatGreeting,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w500,
                        color: c.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, navReserved),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _composer,
              builder: (context, value, _) => ChatComposer(
                controller: _composer,
                hint: l10n.chatComposerHint,
                isSending: _sending,
                isListening: false,
                onSend: _send,
                onMicTap: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
