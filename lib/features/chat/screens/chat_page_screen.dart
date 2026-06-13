import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/appy_nav_bar.dart';
import '../cubit/chat_page_cubit.dart';
import '../cubit/chat_page_state.dart';
import '../widgets/chat_composer_bar.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/chat_suggestions_card.dart';
import '../widgets/chat_top_bar.dart';

/// New illustrated chat page ("Forest Friend" design) — pure UI on mock data.
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatPageCubit(),
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatelessWidget {
  const _ChatView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatPageCubit>();
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
                const _TodayPill(),
                // Conversation fills the remaining space.
                Expanded(
                  child: BlocBuilder<ChatPageCubit, ChatPageState>(
                    buildWhen: (p, c) => p.messages != c.messages,
                    builder: (context, state) =>
                        ChatMessageList(messages: state.messages),
                  ),
                ),
                // Starter suggestions (dismissible).
                BlocBuilder<ChatPageCubit, ChatPageState>(
                  buildWhen: (p, c) => p.showSuggestions != c.showSuggestions,
                  builder: (context, state) => state.showSuggestions
                      ? Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: ChatSuggestionsCard(
                            onPick: cubit.pickSuggestion,
                            onDismiss: cubit.dismissSuggestions,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                // Composer, lifted clear of the floating glass nav bar.
                Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 96.h),
                  child: ChatComposerBar(onSend: cubit.sendMessage),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppyNavBar(),
    );
  }
}

/// Centered frosted "Today" date separator.
class _TodayPill extends StatelessWidget {
  const _TodayPill();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(100.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: ChatPalette.glassPill,
            borderRadius: BorderRadius.circular(100.r),
          ),
          child: Text(
            l10n.chatPageToday,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
