import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../models/chat_mock_data.dart';

/// Scrollable conversation: a frosted "Today" pill leads the list (scrolls with
/// the messages), then Appy bubbles on the left (avatar on each group's first
/// message) and user bubbles on the right with an inline timestamp.
class ChatMessageList extends StatelessWidget {
  final List<ChatBubbleMessage> messages;

  const ChatMessageList({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    // Extra left padding for messages and the avatar; right stays tight.
    return ListView.builder(
      padding: EdgeInsets.only(left: 110.w, right: 16.w, top: 8.h, bottom: 8.h),
      itemCount: messages.length + 1,
      itemBuilder: (context, index) {
        // First item: the centered "Today" date separator.
        if (index == 0) return const _TodayPill();
        final msg = messages[index - 1];
        // Show the avatar only at the start of an Appy group.
        final prev = index - 2;
        final groupStart = !msg.isUser && (prev < 0 || messages[prev].isUser);
        return _Bubble(message: msg, showAvatar: groupStart);
      },
    );
  }
}

/// Centered frosted "Today" date separator that scrolls with the conversation.
class _TodayPill extends StatelessWidget {
  const _TodayPill();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Center(
        child: ClipRRect(
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
        ),
      ),
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
      // User: right-aligned green bubble with the timestamp inside it
      // (WhatsApp-style, bottom-right next to the last line).
      return Padding(
        padding: EdgeInsets.only(top: 3.h, bottom: 3.h),
        child: Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: ChatPalette.userBubble,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.r),
                  topRight: Radius.circular(18.r),
                  bottomLeft: Radius.circular(18.r),
                  bottomRight: Radius.circular(4.r),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
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
                  if (message.time != null) ...[
                    SizedBox(width: 8.w),
                    Padding(
                      padding: EdgeInsets.only(bottom: 1.h),
                      child: Text(
                        message.time!,
                        style: TextStyle(
                          color: ChatPalette.timestamp,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Appy: left-aligned white bubble, avatar on group start.
    return Padding(
      padding: EdgeInsets.only(top: 3.h, bottom: 3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SizedBox(
          //   width: ChatMessageList._avatarSize.w,
          //   child: showAvatar
          //       ? ClipOval(
          //           child: Image.asset(
          //             'assets/chat/appy_avatar.png',
          //             width: ChatMessageList._avatarSize.w,
          //             height: ChatMessageList._avatarSize.w,
          //             fit: BoxFit.cover,
          //           ),
          //         )
          //       : null,
          // ),
          // SizedBox(width: 8.w),
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
