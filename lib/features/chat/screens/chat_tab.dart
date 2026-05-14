import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../memory/cubit/memory_cubit.dart';
import '../../missions/screens/mission_picker_screen.dart';
import '../../mood/cubit/mood_cubit.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../../routines/cubit/routine_cubit.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_list_cubit.dart';
import '../widgets/chat_history_sheet.dart';
import 'chat_screen.dart';

/// Bottom-nav tab that hosts the chat experience.
///
/// - The tab itself shows a landing page (greeting + "Start chat" button).
/// - "Start chat" creates a conversation and pushes [ChatScreen] full-screen
///   above the shell (no bottom nav visible).
/// - History (list icon) opens the modal sheet; picking a conversation pushes
///   [ChatScreen] for it.
class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> with AutomaticKeepAliveClientMixin {
  bool _starting = false;

  @override
  bool get wantKeepAlive => true;

  Future<void> _openHistory() async {
    final picked = await showChatHistorySheet(context);
    if (!mounted || picked == null) return;
    _openChat(picked.id);
  }

  Future<void> _startChat() async {
    if (_starting) return;
    setState(() => _starting = true);
    try {
      final conv = await context.read<ChatListCubit>().createConversation();
      if (!mounted) return;
      setState(() => _starting = false);
      _openChat(conv.id, autoStart: true);
    } catch (e) {
      debugPrint('[ChatTab] createConversation failed: $e');
      if (mounted) setState(() => _starting = false);
    }
  }

  void _openChat(String conversationId, {bool autoStart = false}) {
    final routineCubit = context.read<RoutineCubit>();
    final memoryCubit = context.read<MemoryCubit>();
    final moodCubit = context.read<MoodCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ChatCubit(
            conversationId: conversationId,
            routineCubit: routineCubit,
            memoryCubit: memoryCubit,
            moodCubit: moodCubit,
            autoStart: autoStart,
          ),
          child: BlocProvider.value(
            value: routineCubit,
            child: ChatScreen(onNewChat: _replaceWithNewChat),
          ),
        ),
      ),
    );
  }

  /// Called from the chat page's `+` button: drop the current chat and start
  /// a new one.
  Future<void> _replaceWithNewChat() async {
    Navigator.of(context).pop();
    await _startChat();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _PreChatView(
      onOpenHistory: _openHistory,
      onStartChat: _startChat,
      isStarting: _starting,
    );
  }
}

/// Landing screen shown inside the chat tab.
/// Greeting + "Start chat" button.
class _PreChatView extends StatelessWidget {
  final VoidCallback onOpenHistory;
  final VoidCallback onStartChat;
  final bool isStarting;

  const _PreChatView({
    required this.onOpenHistory,
    required this.onStartChat,
    required this.isStarting,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.bolt_rounded, size: 26.sp, color: c.textPrimary),
          tooltip: l10n.missionPickerTitle,
          onPressed: withMediumHaptic(() {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MissionPickerScreen()),
            );
          }),
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
            icon: Icon(Icons.format_list_bulleted_rounded, size: 22.sp),
            onPressed: withHaptic(onOpenHistory),
          ),
        ],
      ),
      body: Center(
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
              SizedBox(height: 32.h),
              SizedBox(
                height: 52.h,
                child: ElevatedButton(
                  onPressed: isStarting ? null : withHaptic(onStartChat),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26.r),
                    ),
                  ),
                  child: isStarting
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          l10n.chatStartChat,
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
