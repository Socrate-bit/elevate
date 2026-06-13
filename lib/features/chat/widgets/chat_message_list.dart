import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../models/chat_mock_data.dart';

/// Scrollable conversation: Appy bubbles on the left (avatar on each group's
/// first message), user bubbles on the right with a timestamp.
class ChatMessageList extends StatelessWidget {
  final List<ChatBubbleMessage> messages;

  const ChatMessageList({super.key, required this.messages});

  // Avatar column width; non-leading Appy bubbles indent to align under it.
  static const _avatarSize = 34.0;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        // Show the avatar only at the start of an Appy group.
        final groupStart =
            !msg.isUser && (index == 0 || messages[index - 1].isUser);
        return _Bubble(message: msg, showAvatar: groupStart);
      },
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatBubbleMessage message;
  final bool showAvatar;

  const _Bubble({required this.message, required this.showAvatar});

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width * 0.72;

    if (message.isUser) {
      // User: right-aligned green bubble + timestamp below.
      return Padding(
        padding: EdgeInsets.only(top: 6.h, bottom: 6.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: ChatPalette.userBubble,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.r),
                    topRight: Radius.circular(18.r),
                    bottomLeft: Radius.circular(18.r),
                    bottomRight: Radius.circular(4.r),
                  ),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: ChatPalette.userText,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ),
            ),
            if (message.time != null) ...[
              SizedBox(height: 4.h),
              Text(
                message.time!,
                style: TextStyle(
                  color: ChatPalette.timestamp,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Appy: left-aligned white bubble, avatar on group start.
    return Padding(
      padding: EdgeInsets.only(top: 6.h, bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: ChatMessageList._avatarSize.w,
            child: showAvatar
                ? ClipOval(
                    child: Image.asset(
                      'assets/chat/appy_avatar.png',
                      width: ChatMessageList._avatarSize.w,
                      height: ChatMessageList._avatarSize.w,
                      fit: BoxFit.cover,
                    ),
                  )
                : null,
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: ChatPalette.appyBubble,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18.r),
                      topRight: Radius.circular(18.r),
                      bottomLeft: Radius.circular(4.r),
                      bottomRight: Radius.circular(18.r),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: ChatPalette.appyText,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
