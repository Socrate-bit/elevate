import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../cubit/chat_list_cubit.dart';
import '../cubit/chat_list_state.dart';
import '../services/chat_conversation.dart';
import 'conversation_tile.dart';

/// Opens a draggable modal sheet listing the user's conversations with search.
/// Resolves with the [ChatConversation] the user picked, or null on dismiss.
Future<ChatConversation?> showChatHistorySheet(BuildContext context) {
  final cubit = context.read<ChatListCubit>();
  return showModalBottomSheet<ChatConversation>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.of(context).background,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (_) =>
        BlocProvider.value(value: cubit, child: const _ChatHistorySheet()),
  );
}

class _ChatHistorySheet extends StatefulWidget {
  const _ChatHistorySheet();

  @override
  State<_ChatHistorySheet> createState() => _ChatHistorySheetState();
}

class _ChatHistorySheetState extends State<_ChatHistorySheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (sheetCtx, scroll) => BlocBuilder<ChatListCubit, ChatListState>(
        builder: (blocCtx, state) {
          // Hide empty-title conversations (created but never sent to).
          final items = state.filtered
              .where((conv) => conv.title.isNotEmpty)
              .toList();
          return Column(
            children: [
              _Handle(),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 12.h),
                child: Text(
                  l10n.chatHistoryTitle,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                child: _SearchField(
                  controller: _searchController,
                  hint: l10n.chatHistorySearchHint,
                  onChanged: (q) =>
                      blocCtx.read<ChatListCubit>().setSearchQuery(q),
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? _EmptyState(searchActive: state.searchQuery.isNotEmpty)
                    : ListView.separated(
                        controller: scroll,
                        padding: EdgeInsets.only(bottom: 24.h),
                        itemCount: items.length,
                        separatorBuilder: (context, i) => Divider(
                          height: 1,
                          thickness: 0.5,
                          color: c.separator,
                          indent: 20.w,
                          endIndent: 20.w,
                        ),
                        itemBuilder: (tileCtx, i) {
                          final conv = items[i];
                          return ConversationTile(
                            conversation: conv,
                            onTap: () => Navigator.pop(context, conv),
                            onDelete: () => blocCtx
                                .read<ChatListCubit>()
                                .deleteConversation(conv.id),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
      child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: c.separator,
          borderRadius: BorderRadius.circular(2.r),
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
                hintStyle: TextStyle(fontSize: 15.sp, color: c.textSecondary),
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
              size: 48.sp,
              color: c.textSecondary,
            ),
            SizedBox(height: 12.h),
            Text(
              l10n.chatHistoryEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
            if (!searchActive) ...[
              SizedBox(height: 6.h),
              Text(
                l10n.chatHistoryEmptyHint,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, color: c.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
