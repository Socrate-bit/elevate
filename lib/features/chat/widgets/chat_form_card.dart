import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../services/chat_form.dart';

/// Renders a multiple-choice card emitted by Gemini via `present_choices`.
/// Buttons stay tappable until the user picks one, then lock and highlight.
class ChatFormCard extends StatelessWidget {
  final ChatForm form;
  final ValueChanged<int> onAnswer;

  const ChatFormCard({super.key, required this.form, required this.onAnswer});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isAnswered = form.selectedIndex != null;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.85.sw),
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              form.question,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
                height: 1.35,
              ),
            ),
            SizedBox(height: 10.h),
            ...List.generate(form.options.length, (i) {
              final isSelected = form.selectedIndex == i;
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: GestureDetector(
                  onTap: isAnswered ? null : withHaptic(() => onAnswer(i)),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? c.primary : c.background,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected ? c.primary : c.separator,
                      ),
                    ),
                    child: Text(
                      form.options[i],
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : c.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
