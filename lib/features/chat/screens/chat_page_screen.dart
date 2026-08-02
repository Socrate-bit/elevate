import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../../adventure/cubit/adventure_cubit.dart';
import '../../navigation/appy_nav_bar.dart';
import '../../memory/cubit/memory_cubit.dart';
import '../../mood/cubit/mood_cubit.dart';
import '../../routines/cubit/routine_cubit.dart';
import '../../subscription/services/analytics_service.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_list_cubit.dart';
import '../cubit/chat_list_state.dart';
import '../cubit/chat_state.dart';
import '../services/chat_message.dart';
import '../widgets/chat_composer_bar.dart';
import '../widgets/chat_proposed_answers_panel.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/chat_suggestions_card.dart';
import '../widgets/chat_top_bar.dart';
import '../widgets/insight_progress_button.dart';

/// Illustrated "Forest Friend" chat page. Renders the cozy-room scene, header,
/// and floating nav; the conversation itself is driven by the real [ChatCubit]
/// via [_ChatConversationGate] (a single ongoing conversation that resumes).
class ChatPage extends StatelessWidget {
  /// When true, the page is shown as a standalone pushed route: the bottom nav
  /// bar is hidden and a back button is overlaid to pop back.
  final bool fullScreen;

  /// When true, the 3-option starter card is shown even if the resumed
  /// conversation already has messages — lets the introspection task "restart
  /// the workflow" on the ongoing conversation.
  final bool forceStarter;

  const ChatPage({
    super.key,
    this.fullScreen = false,
    this.forceStarter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomePalette.cream,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                SizedBox(height: 6.h),
                // The header lives inside the conversation gate so the insight
                // progress button can read the ChatCubit provided there.
                Expanded(
                  child: _ChatConversationGate(forceStarter: forceStarter),
                ),
              ],
            ),
          ),
          // Full-page presentation: back button overlaid top-left, centered
          // header untouched.
          if (fullScreen)
            SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 4.w, top: 4.h),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: ChatPalette.headerTitle,
                      size: 20.sp,
                    ),
                    onPressed: withHaptic(
                      () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: fullScreen ? null : const AppyNavBar(),
    );
  }
}

/// Resolves the single conversation for the chat (resume the most recent, or
/// create one if none exists) and provides a [ChatCubit] for it. Chat is a
/// full-page pushed route, so this gate is created on open and disposed on
/// close — which is what drives the on-enter / on-leave memory extraction.
class _ChatConversationGate extends StatefulWidget {
  const _ChatConversationGate({this.forceStarter = false});

  /// Forces the starter card to show on the resumed conversation.
  final bool forceStarter;

  @override
  State<_ChatConversationGate> createState() => _ChatConversationGateState();
}

class _ChatConversationGateState extends State<_ChatConversationGate> {
  String? _resolvedId;
  bool _autoStart = false;
  Timer? _fallbackTimer;

  /// Hard stop so the tab can never show a spinner forever: if the conversations
  /// stream hasn't produced anything actionable in time, create one anyway.
  /// Short enough that a first-time user (no conversations) isn't left waiting,
  /// but long enough for an existing conversation to load first and be resumed.
  static const _resolveTimeout = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    // Attempt resolution against whatever the conversations stream already has.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _tryResolve(context.read<ChatListCubit>().state);
    });
    // Fallback: if nothing resolved us in time (stream stuck loading, etc.),
    // force-create a conversation so the user is never stuck on a spinner.
    _fallbackTimer = Timer(_resolveTimeout, () {
      if (!mounted || _resolvedId != null) return;
      debugPrint('[ChatPage] resolve timed out → forcing new conversation');
      _tryResolve(context.read<ChatListCubit>().state, force: true);
    });
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    super.dispose();
  }

  /// Picks the most-recent conversation, or creates one if the user has none.
  /// Runs once — pinned via [_resolvedId] so later stream updates don't swap it.
  /// [force] skips the "still loading" wait (used by the timeout fallback).
  void _tryResolve(ChatListState s, {bool force = false}) {
    if (_resolvedId != null) return;

    // Prefer an existing conversation (resume where the user left off).
    if (s.conversations.isNotEmpty) {
      final conv = s.conversations.first;
      debugPrint('[ChatPage] resuming conversation ${conv.id}');
      _fallbackTimer?.cancel();
      setState(() {
        _resolvedId = conv.id;
        _autoStart = false; // resume — no fresh greeting
      });
      return;
    }

    // No conversation yet. Wait for the first snapshot unless it's still loading
    // and we haven't hit the timeout — then create one (non-blocking) and greet.
    if (s.isLoading && !force) {
      debugPrint('[ChatPage] waiting for conversations snapshot…');
      return;
    }

    _fallbackTimer?.cancel();
    final conv = context.read<ChatListCubit>().newConversation();
    debugPrint('[ChatPage] created new conversation ${conv.id}');
    setState(() {
      _resolvedId = conv.id;
      _autoStart = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatListCubit, ChatListState>(
      listener: (_, state) => _tryResolve(state),
      child: _resolvedId == null
          ? const _ResolvingPlaceholder()
          : BlocProvider<ChatCubit>(
              create: (_) => ChatCubit(
                conversationId: _resolvedId!,
                routineCubit: context.read<RoutineCubit>(),
                memoryCubit: context.read<MemoryCubit>(),
                moodCubit: context.read<MoodCubit>(),
                adventureCubit: context.read<AdventureCubit>(),
                autoStart: _autoStart,
              ),
              child: _ChatView(forceStarter: widget.forceStarter),
            ),
    );
  }
}

/// Frosted spinner shown briefly over the scene while the single conversation
/// is being resolved. A timeout in the gate guarantees this never lingers.
class _ResolvingPlaceholder extends StatelessWidget {
  const _ResolvingPlaceholder();

  @override
  Widget build(BuildContext context) {
    // Keep the header visible (title only — no cubit yet for the insight button)
    // so it doesn't flash in once the conversation resolves.
    return Column(
      children: [
        const ChatTopBar(),
        SizedBox(height: 10.h),
        Expanded(
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: ChatPalette.glassPill,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: SizedBox(
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
        ),
      ],
    );
  }
}

/// The live conversation column: messages, starter suggestions, and composer.
/// Owns the text/scroll controllers and the ephemeral "suggestions dismissed"
/// flag (kept out of [ChatState] so the backend contract stays clean).
class _ChatView extends StatefulWidget {
  const _ChatView({this.forceStarter = false});

  /// Shows the starter card even when the conversation already has messages.
  final bool forceStarter;

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> with WidgetsBindingObserver {
  final _composer = TextEditingController();
  final _composerFocus = FocusNode();
  final _scrollController = ScrollController();
  bool _suggestionsDismissed = false;

  /// Whether the inline rapid-answers panel is unfolded above the composer.
  bool _proposalsOpen = false;

  @override
  void initState() {
    super.initState();
    // Observe view-inset changes so we can keep the last message visible as the
    // keyboard animates in/out (message-driven scrolling alone doesn't cover it).
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _composer.dispose();
    _composerFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Fires on every keyboard animation frame — keep pinned to the latest message
  /// so the composer never hides it once the keyboard is open.
  @override
  void didChangeMetrics() {
    // Jump (not animate) so we track the growing extent frame-by-frame instead
    // of lagging behind a 200ms tween as the keyboard slides in.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  /// Handles a tapped starter chip — each intent behaves differently.
  void _onStarterPick(BuildContext context, ChatSuggestion suggestion) {
    switch (suggestion.action) {
      case ChatStarterAction.askQuestion:
        // Appy asks an opening question; hide the card while it replies.
        setState(() => _suggestionsDismissed = true);
        context.read<ChatCubit>().promptOpeningQuestion();
      case ChatStarterAction.letMeType:
        // Nothing sent — just dismiss and open the keyboard on the composer.
        setState(() => _suggestionsDismissed = true);
        _composerFocus.requestFocus();
      case ChatStarterAction.sendAsMessage:
        // Send the label as a user message; dismiss so the card also hides
        // when forced open on a conversation that already has messages.
        setState(() => _suggestionsDismissed = true);
        _send(context, suggestion.label);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Header with the insight progress button (needs the ChatCubit provided
        // by the enclosing gate, so it lives here rather than at page level).
        ChatTopBar(trailing: const InsightProgressButton()),
        SizedBox(height: 10.h),
        // Hairline separating the header from the conversation.
        Divider(height: 1, thickness: 1, color: ChatPalette.cardBorder),
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
        // // Starter suggestions — visible until dismissed or the user has spoken.
        // BlocBuilder<ChatCubit, ChatState>(
        //   buildWhen: (a, b) => a.messages != b.messages,
        //   builder: (context, state) {
        //     final hasUserMessage = state.messages.any(
        //       (m) => m.role == ChatRole.user,
        //     );
        //     // Normally the card hides once the user has spoken; when forced
        //     // (introspection "restart workflow") it shows regardless, until the
        //     // user picks an option or dismisses it.
        //     if (_suggestionsDismissed ||
        //         (!widget.forceStarter && hasUserMessage)) {
        //       return const SizedBox.shrink();
        //     }
        //     return Padding(
        //       padding: EdgeInsets.only(bottom: 10.h),
        //       child: ChatSuggestionsCard(
        //         onPick: (suggestion) => _onStarterPick(context, suggestion),
        //         onDismiss: () => setState(() => _suggestionsDismissed = true),
        //       ),
        //     );
        //   },
        // ),
        // Hairline separating the conversation from the composer.
        Divider(height: 1, thickness: 1, color: ChatPalette.cardBorder),
        // Inline rapid-answers panel — rendered in the column (not a modal
        // route) so unfolding it never dismisses the keyboard.
        BlocBuilder<ChatCubit, ChatState>(
          buildWhen: (a, b) => a.proposedAnswers != b.proposedAnswers,
          builder: (context, state) {
            if (!_proposalsOpen || state.proposedAnswers.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 0),
              child: ChatProposedAnswersPanel(
                answers: state.proposedAnswers,
                onPick: (text) {
                  AnalyticsService.capture(
                    AnalyticsService.chatProposedAnswerTapped,
                  );
                  _send(context, text);
                },
              ),
            );
          },
        ),
        // Composer: snug above the keyboard when open, clear of the floating nav
        // bar when closed (padding grows smoothly to 96 as the keyboard retracts).
        Padding(
          padding: EdgeInsets.fromLTRB(
            24.w,
            6,
            24.w,
            (24.h - MediaQuery.viewInsetsOf(context).bottom).clamp(8.h, 96.h),
          ),
          child: BlocBuilder<ChatCubit, ChatState>(
            buildWhen: (a, b) => a.proposedAnswers != b.proposedAnswers,
            builder: (context, state) => ChatComposerBar(
              controller: _composer,
              focusNode: _composerFocus,
              hint: l10n.chatPageComposerHint,
              onSend: () => _send(context, _composer.text),
              proposedAnswers: state.proposedAnswers,
              onToggleProposed: () =>
                  setState(() => _proposalsOpen = !_proposalsOpen),
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
    // Fold the rapid-answers panel so it stays collapsed by default rather than
    // auto-unfolding on the next AI turn.
    if (_proposalsOpen) setState(() => _proposalsOpen = false);
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

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }
}
