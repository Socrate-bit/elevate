import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../models/community_mock_data.dart';

/// Messages segment: a list of direct-message conversation previews.
class CommunityMessagesView extends StatelessWidget {
  const CommunityMessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    const messages = CommunityMockData.messages;
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
      itemCount: messages.length,
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
      itemBuilder: (context, i) => _MessageRow(message: messages[i]),
    );
  }
}

/// A single conversation row.
class _MessageRow extends StatelessWidget {
  final CommunityMessage message;
  const _MessageRow({required this.message});

  @override
  Widget build(BuildContext context) {
    final unread = message.unread > 0;
    return GestureDetector(
      onTap: withHaptic(() {}),
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
              backgroundImage: AssetImage(message.avatar),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: CommunityPalette.textDark,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    message.lastMessage,
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
                  message.timeAgo,
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
                      '${message.unread}',
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
