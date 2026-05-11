import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../services/chat_message.dart';
import '../services/voice_service.dart';
import '../widgets/chat_composer.dart';
import '../widgets/chat_form_card.dart';
import '../widgets/message_bubble.dart';

/// Active conversation rendered inside the bottom-nav shell.
/// Top bar: list icon (open history) left, `+` icon (new chat) right.
class ChatScreen extends StatefulWidget {
  final VoidCallback onOpenHistory;
  final VoidCallback onNewChat;

  const ChatScreen({
    super.key,
    required this.onOpenHistory,
    required this.onNewChat,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _composer = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _composer.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _composer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    // Reserve space for the bottom nav so the composer/messages don't overlap.
    final navReserved = MediaQuery.viewPaddingOf(context).bottom + 84.h;

    return BlocConsumer<ChatCubit, ChatState>(
      listenWhen: (a, b) => a.messages.length != b.messages.length,
      listener: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      },
      builder: (context, state) {
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
                onPressed: withMediumHaptic(widget.onNewChat),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: state.messages.isEmpty && !state.isLoading
                    ? _GreetingHero()
                    : state.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _MessagesList(
                            scrollController: _scrollController,
                            messages: state.messages,
                            isSending: state.isSending,
                            bottomPadding: navReserved + 80.h,
                          ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, navReserved),
                child: ChatComposer(
                  controller: _composer,
                  hint: state.isListening
                      ? l10n.chatVoiceListening
                      : l10n.chatComposerHint,
                  isSending: state.isSending,
                  isListening: state.isListening,
                  onSend: () => _send(context),
                  onMicTap: () => _toggleMic(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _send(BuildContext context) async {
    final text = _composer.text.trim();
    if (text.isEmpty) return;
    _composer.clear();
    final l10n = AppLocalizations.of(context)!;
    try {
      await context.read<ChatCubit>().sendText(text);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.chatSendFailed)),
      );
    }
  }

  Future<void> _toggleMic(BuildContext context) async {
    final cubit = context.read<ChatCubit>();
    final l10n = AppLocalizations.of(context)!;
    if (cubit.state.isListening) {
      final transcript = await cubit.stopListening();
      if (transcript.trim().isNotEmpty) {
        _composer.text = transcript;
      }
    } else {
      try {
        await cubit.startListening();
        // Mirror partial transcripts into the composer for visual feedback.
        _bindPartialUpdates(cubit);
      } on VoiceUnavailableException {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.chatVoiceUnavailable)),
        );
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.chatVoicePermissionDenied)),
        );
      }
    }
  }

  void _bindPartialUpdates(ChatCubit cubit) {
    final sub = cubit.stream.listen((s) {
      if (s.voicePartial.isNotEmpty && s.voicePartial != _composer.text) {
        _composer.text = s.voicePartial;
        _composer.selection = TextSelection.collapsed(
          offset: _composer.text.length,
        );
      }
    });
    cubit.stream
        .firstWhere((s) => !s.isListening)
        .then((_) => sub.cancel());
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }
}

class _MessagesList extends StatelessWidget {
  final ScrollController scrollController;
  final List<ChatMessage> messages;
  final bool isSending;
  final double bottomPadding;

  const _MessagesList({
    required this.scrollController,
    required this.messages,
    required this.isSending,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = messages.length + (isSending ? 1 : 0);
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, bottomPadding),
      itemCount: itemCount,
      itemBuilder: (ctx, i) {
        if (isSending && i == messages.length) {
          return const _TypingIndicator();
        }
        final m = messages[i];
        if (m.form != null && m.role == ChatRole.model) {
          return ChatFormCard(
            form: m.form!,
            onAnswer: (idx) =>
                context.read<ChatCubit>().answerForm(m.id, idx),
          );
        }
        return MessageBubble(message: m);
      },
    );
  }
}

class _GreetingHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Center(
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
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.r),
            topRight: Radius.circular(18.r),
            bottomLeft: Radius.circular(4.r),
            bottomRight: Radius.circular(18.r),
          ),
        ),
        child: SizedBox(
          width: 36.w,
          height: 12.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              3,
              (_) => Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  color: c.textSecondary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
