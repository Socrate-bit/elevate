import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../../mood/models/mood_entry.dart';
import '../cubit/chat_cubit.dart';
import '../services/chat_mood_check_in.dart';

/// Inline mood check-in card rendered inside a model message bubble.
class ChatMoodCheckInCard extends StatelessWidget {
  final String messageId;
  final ChatMoodCheckIn checkIn;

  const ChatMoodCheckInCard({
    super.key,
    required this.messageId,
    required this.checkIn,
  });

  @override
  Widget build(BuildContext context) {
    final answered = checkIn.selectedMood != null;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.78.sw),
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: ChatPalette.appyBubble,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.r),
            topRight: Radius.circular(18.r),
            bottomLeft: Radius.circular(4.r),
            bottomRight: Radius.circular(18.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              checkIn.question,
              style: TextStyle(
                fontSize: 15.sp,
                color: ChatPalette.appyText,
                height: 1.35,
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: MoodValue.values.map((mood) {
                final isSelected = checkIn.selectedMood == mood;
                final isDisabled = answered && !isSelected;
                return GestureDetector(
                  onTap: answered
                      ? null
                      : withHaptic(
                          () => context.read<ChatCubit>().selectMood(
                            messageId,
                            mood,
                          ),
                        ),
                  child: Opacity(
                    opacity: isDisabled ? 0.3 : 1.0,
                    child: Column(
                      children: [
                        Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            color: mood.color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: ChatPalette.appyText,
                                    width: 2.5,
                                  )
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              mood.emoji,
                              style: TextStyle(fontSize: 22.sp),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
