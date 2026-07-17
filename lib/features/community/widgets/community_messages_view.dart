import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/community_cubit.dart';
import '../cubit/community_state.dart';
import '../models/community_conversation.dart';
import '../screens/community_dm_screen.dart';
import '../utils/community_time.dart';

/// Messages segment: a list of direct-message conversation previews.
class CommunityMessagesView extends StatelessWidget {
  const CommunityMessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<CommunityCubit, CommunityState>(
      buildWhen: (p, c) =>
          p.conversations != c.conversations || p.currentUid != c.currentUid,
      builder: (context, state) {
        final uid = state.currentUid;
        final conversations = state.conversations;
        if (uid == null || conversations.isEmpty) {
          return Center(
            child: Text(
              l10n.communityMessagesEmpty,
              style: TextStyle(
                fontSize: 13.sp,
                color: CommunityPalette.subtitleGrey,
              ),
            ),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
          itemCount: conversations.length,
          separatorBuilder: (_, _) => SizedBox(height: 10.h),
          itemBuilder: (context, i) => _MessageRow(
            conversation: conversations[i],
            currentUid: uid,
          ),
        );
      },
    );
  }
}

/// A single conversation row.
class _MessageRow extends StatelessWidget {
  final CommunityConversation conversation;
  final String currentUid;

  const _MessageRow({required this.conversation, required this.currentUid});

  @override
  Widget build(BuildContext context) {
    final otherUid = conversation.otherUid(currentUid);
    final unreadCount = conversation.unreadFor(currentUid);
    final unread = unreadCount > 0;
    return GestureDetector(
      onTap: withHaptic(() {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CommunityDmScreen(
              conversation: conversation,
              currentUid: currentUid,
            ),
          ),
        );
      }),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: CommunityPalette.card,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22.w,
              backgroundColor: CommunityPalette.background,
              backgroundImage:
                  AssetImage(conversation.avatarAssetFor(otherUid)),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.usernameFor(otherUid),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: CommunityPalette.textDark,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    conversation.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: unread ? FontWeight.w700 : FontWeight.w400,
                      color: unread
                          ? CommunityPalette.textDark
                          : CommunityPalette.subtitleGrey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  communityTimeAgo(conversation.lastMessageAt),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: CommunityPalette.subtitleGrey,
                  ),
                ),
                SizedBox(height: 6.h),
                if (unread)
                  Container(
                    width: 20.w,
                    height: 20.w,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: CommunityPalette.unreadDot,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$unreadCount',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  )
                else
                  SizedBox(height: 20.w),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
