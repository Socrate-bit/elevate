import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import 'package:elevate/features/shell/widgets/appy_nav_bar.dart';
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
                // Conversation fills the remaining space. The "Today" pill now
                // scrolls with the messages rather than sitting in the top bar.
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
                // Composer: snug above the keyboard when open, clear of the
                // floating nav bar when closed. As the keyboard retracts the
                // padding grows smoothly to 96 instead of snapping — so the
                // composer never dips behind the nav bar mid-animation.
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    12.w,
                    0,
                    12.w,
                    (96.h - MediaQuery.viewInsetsOf(context).bottom).clamp(
                      8.h,
                      96.h,
                    ),
                  ),
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
