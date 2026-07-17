import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/appy_nav_bar.dart';
import '../../memory/cubit/memory_cubit.dart';
import '../../mood/cubit/mood_cubit.dart';
import '../../routines/cubit/routine_cubit.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_list_cubit.dart';
import '../cubit/chat_list_state.dart';
import '../cubit/chat_state.dart';
import '../services/chat_message.dart';
import '../services/voice_service.dart';
import '../widgets/chat_composer_bar.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/chat_suggestions_card.dart';
import '../widgets/chat_top_bar.dart';

/// Illustrated "Forest Friend" chat page. Renders the cozy-room scene, header,
/// and floating nav; the conversation itself is driven by the real [ChatCubit]
/// via [_ChatConversationGate] (a single ongoing conversation that resumes).
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomePalette.cream,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Full-bleed cozy-room scene.
          Positioned.fill(
            child: Image.asset(
              'assets/chat/chat_background.png',
              fit: BoxFit.cover,
            ),
          ),
          // Soft top fade so the status bar and header stay legible.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160.h,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x40FFFFFF), Color(0x00FFFFFF)],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                SizedBox(height: 6.h),
                const ChatTopBar(),
                SizedBox(height: 10.h),
                const Expanded(child: _ChatConversationGate()),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppyNavBar(),
    );
  }
}

/// Resolves the single conversation for the tab (resume the most recent, or
/// create one if none exists) and provides a [ChatCubit] for it. Lives inside
/// the always-alive shell `IndexedStack`, so the cubit is created once and its
/// state survives tab switches.
class _ChatConversationGate extends StatefulWidget {
  const _ChatConversationGate();

  @override
  State<_ChatConversationGate> createState() => _ChatConversationGateState();
}

class _ChatConversationGateState extends State<_ChatConversationGate>
    with WidgetsBindingObserver {
  String? _resolvedId;
  bool _autoStart = false;
  bool _creating = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Attempt resolution against whatever the conversations stream already has.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _tryResolve(context.read<ChatListCubit>().state);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The page is never disposed inside the IndexedStack, so ChatCubit.close()
    // (which triggers memory extraction) won't fire. Extract on background as a
    // best-effort stand-in; MemoryCubit also runs a catch-up on next launch.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      final id = _resolvedId;
      if (id != null && mounted) {
        context.read<MemoryCubit>().extractNow(id);
      }
    }
  }

  /// Picks the most-recent conversation, or creates one if the user has none.
  /// Runs once — pinned via [_resolvedId] so later stream updates don't swap it.
  void _tryResolve(ChatListState s) {
    if (_resolvedId != null || _creating) return;
    // Still waiting for the first conversations snapshot.
    if (s.isLoading && s.conversations.isEmpty) return;

    if (s.conversations.isNotEmpty) {
      setState(() {
        _resolvedId = s.conversations.first.id;
        _autoStart = false; // resume — no fresh greeting
        _failed = false;
      });
      return;
    }

    // No conversation yet — create one lazily and greet the user.
    _creating = true;
    _failed = false;
    context
        .read<ChatListCubit>()
        .createConversation()
        .then((conv) {
          if (!mounted) return;
          setState(() {
            _resolvedId = conv.id;
            _autoStart = true;
            _creating = false;
          });
        })
        .catchError((Object e) {
          debugPrint('[ChatPage] createConversation failed: $e');
          if (mounted) {
            setState(() {
              _creating = false;
              _failed = true;
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatListCubit, ChatListState>(
      listener: (_, state) => _tryResolve(state),
      child: _resolvedId == null
          ? _ResolvingPlaceholder(
              failed: _failed,
              onRetry: () => _tryResolve(context.read<ChatListCubit>().state),
            )
          : BlocProvider<ChatCubit>(
              create: (_) => ChatCubit(
                conversationId: _resolvedId!,
                routineCubit: context.read<RoutineCubit>(),
                memoryCubit: context.read<MemoryCubit>(),
                moodCubit: context.read<MoodCubit>(),
                autoStart: _autoStart,
              ),
              child: const _ChatView(),
            ),
    );
  }
}

/// Frosted loading (or tap-to-retry) shown over the scene while the single
/// conversation is being resolved/created.
class _ResolvingPlaceholder extends StatelessWidget {
  final bool failed;
  final VoidCallback onRetry;

  const _ResolvingPlaceholder({required this.failed, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: GestureDetector(
            onTap: failed ? onRetry : null,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: ChatPalette.glassPill,
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: failed
                  ? Text(
                      l10n.chatSendFailed,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The live conversation column: messages, starter suggestions, and composer.
/// Owns the text/scroll controllers and the ephemeral "suggestions dismissed"
/// flag (kept out of [ChatState] so the backend contract stays clean).
class _ChatView extends StatefulWidget {
  const _ChatView();

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _composer = TextEditingController();
  final _scrollController = ScrollController();
  bool _suggestionsDismissed = false;

  @override
  void dispose() {
    _composer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Conversation fills the remaining space; auto-scrolls on new turns.
        Expanded(
          child: BlocConsumer<ChatCubit, ChatState>(
            listenWhen: (a, b) =>
                a.messages.length != b.messages.length ||
                a.isSending != b.isSending,
            listener: (context, state) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _scrollToBottom(),
              );
            },
            builder: (context, state) {
              if (state.isLoading && state.messages.isEmpty) {
                return const SizedBox.shrink();
              }
              return ChatMessageList(
                messages: state.messages,
                isSending: state.isSending,
                controller: _scrollController,
              );
            },
          ),
        ),
        // Starter suggestions — visible until dismissed or the user has spoken.
        BlocBuilder<ChatCubit, ChatState>(
          buildWhen: (a, b) => a.messages != b.messages,
          builder: (context, state) {
            final hasUserMessage = state.messages.any(
              (m) => m.role == ChatRole.user,
            );
            if (_suggestionsDismissed || hasUserMessage) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: ChatSuggestionsCard(
                onPick: (label) => _send(context, label),
                onDismiss: () => setState(() => _suggestionsDismissed = true),
              ),
            );
          },
        ),
        // Composer: snug above the keyboard when open, clear of the floating nav
        // bar when closed (padding grows smoothly to 96 as the keyboard retracts).
        Padding(
          padding: EdgeInsets.fromLTRB(
            12.w,
            0,
            12.w,
            (96.h - MediaQuery.viewInsetsOf(context).bottom).clamp(8.h, 96.h),
          ),
          child: BlocBuilder<ChatCubit, ChatState>(
            buildWhen: (a, b) => a.isListening != b.isListening,
            builder: (context, state) => ChatComposerBar(
              controller: _composer,
              hint: state.isListening
                  ? l10n.chatVoiceListening
                  : l10n.chatPageComposerHint,
              isListening: state.isListening,
              onSend: () => _send(context, _composer.text),
              onMic: () => _toggleMic(context),
            ),
          ),
        ),
      ],
    );
  }

  /// Sends [raw] as a user turn (from the composer or a suggestion chip).
  Future<void> _send(BuildContext context, String raw) async {
    final text = raw.trim();
    if (text.isEmpty) return;
    _composer.clear();
    final l10n = AppLocalizations.of(context)!;
    try {
      await context.read<ChatCubit>().sendText(text);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.chatSendFailed)));
    }
  }

  Future<void> _toggleMic(BuildContext context) async {
    final cubit = context.read<ChatCubit>();
    final l10n = AppLocalizations.of(context)!;
    if (cubit.state.isListening) {
      final transcript = await cubit.stopListening();
      if (transcript.trim().isNotEmpty) _composer.text = transcript;
      return;
    }
    try {
      await cubit.startListening();
      _bindPartialUpdates(cubit);
    } on VoiceUnavailableException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.chatVoiceUnavailable)));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.chatVoicePermissionDenied)));
    }
  }

  /// Mirrors live partial transcripts into the composer while listening.
  void _bindPartialUpdates(ChatCubit cubit) {
    final sub = cubit.stream.listen((s) {
      if (s.voicePartial.isNotEmpty && s.voicePartial != _composer.text) {
        _composer.text = s.voicePartial;
        _composer.selection = TextSelection.collapsed(
          offset: _composer.text.length,
        );
      }
    });
    cubit.stream.firstWhere((s) => !s.isListening).then((_) => sub.cancel());
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
