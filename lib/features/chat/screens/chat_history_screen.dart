import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_list_cubit.dart';
import '../cubit/chat_list_state.dart';
import '../services/chat_conversation.dart';
import '../widgets/conversation_tile.dart';
import 'chat_screen.dart';

/// Conversation history with search + new-chat FAB. Lives as a bottom-nav tab.
class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen>
    with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bottomNavPadding = MediaQuery.viewPaddingOf(context).bottom + 80.h;

    return BlocBuilder<ChatListCubit, ChatListState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: c.background,
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              l10n.chatHistoryTitle,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: state.isLoading && state.conversations.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : state.filtered.isEmpty
                        ? _EmptyState(searchActive: state.searchQuery.isNotEmpty)
                        : ListView.separated(
                            padding: EdgeInsets.only(
                              top: 8.h,
                              bottom: bottomNavPadding + 120.h,
                            ),
                            itemCount: state.filtered.length,
                            separatorBuilder: (context, i) => Divider(
                              height: 1,
                              thickness: 0.5,
                              color: c.separator,
                              indent: 20.w,
                              endIndent: 20.w,
                            ),
                            itemBuilder: (ctx, i) {
                              final conv = state.filtered[i];
                              return ConversationTile(
                                conversation: conv,
                                onTap: () => _openChat(context, conv),
                                onDelete: () => context
                                    .read<ChatListCubit>()
                                    .deleteConversation(conv.id),
                              );
                            },
                          ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  4.h,
                  16.w,
                  bottomNavPadding,
                ),
                child: _SearchField(
                  controller: _searchController,
                  hint: l10n.chatHistorySearchHint,
                  onChanged: (q) =>
                      context.read<ChatListCubit>().setSearchQuery(q),
                ),
              ),
            ],
          ),
          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: bottomNavPadding - 40.h),
            child: FloatingActionButton(
              backgroundColor: c.primary,
              foregroundColor: Colors.white,
              onPressed: withMediumHaptic(() => _newChat(context)),
              child: const Icon(Icons.add_rounded),
            ),
          ),
        );
      },
    );
  }

  Future<void> _newChat(BuildContext context) async {
    try {
      final conv = await context.read<ChatListCubit>().createConversation();
      if (!context.mounted) return;
      _openChat(context, conv);
    } catch (_) {
      // Error already surfaced via debugPrint; nothing user-facing to add.
    }
  }

  void _openChat(BuildContext context, ChatConversation conv) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ChatCubit(conversationId: conv.id),
          child: ChatScreen(conversation: conv),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: c.separator),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 20.sp, color: c.textSecondary),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(fontSize: 15.sp, color: c.textPrimary),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 15.sp,
                  color: c.textSecondary,
                ),
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool searchActive;
  const _EmptyState({required this.searchActive});

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
            Icon(
              Icons.chat_bubble_outline,
              size: 56.sp,
              color: c.textSecondary,
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.chatHistoryEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
            if (!searchActive) ...[
              SizedBox(height: 6.h),
              Text(
                l10n.chatHistoryEmptyHint,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: c.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
