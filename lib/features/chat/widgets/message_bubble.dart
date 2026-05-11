import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../services/chat_message.dart';

/// Renders a single text bubble — right-aligned brand color for the user,
/// left-aligned neutral card color for the model.
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isUser = message.role == ChatRole.user;
    final bgColor = isUser ? c.primary : c.card;
    final textColor = isUser ? Colors.white : c.textPrimary;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.78.sw),
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.r),
            topRight: Radius.circular(18.r),
            bottomLeft: Radius.circular(isUser ? 18.r : 4.r),
            bottomRight: Radius.circular(isUser ? 4.r : 18.r),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(fontSize: 15.sp, color: textColor, height: 1.35),
        ),
      ),
    );
  }
}
