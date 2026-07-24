import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';

/// Minimalist composer: a white pill (matching the page background) holding the
/// text field and a trailing action. The trailing icon is a mic while the field
/// is empty (tap → [onMic]) and a send arrow once there is text (tap → [onSend]).
/// The field grows from one to three lines. Controlled by the parent, which owns
/// [controller].
class ChatComposerBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isListening;
  final VoidCallback onSend;
  final VoidCallback onMic;

  const ChatComposerBar({
    super.key,
    required this.controller,
    required this.hint,
    required this.isListening,
    required this.onSend,
    required this.onMic,
  });

  @override
  Widget build(BuildContext context) {
    // Rebuild the trailing icon as the text changes (empty → mic, text → send).
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final hasText = controller.text.trim().isNotEmpty;
        // White pill holding the text field + trailing action. Bottom-aligned so
        // the action stays anchored as the field grows from one to three lines.
        return Container(
          padding: EdgeInsets.only(left: 18.w, right: 8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: ChatPalette.cardBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) {
                    if (controller.text.trim().isNotEmpty) onSend();
                  },
                  style: TextStyle(
                    color: ChatPalette.userText,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: ChatPalette.headerSubtitle,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              GestureDetector(
                onTap: withHaptic(hasText ? onSend : onMic),
                child: Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Icon(
                    hasText
                        ? Icons.arrow_upward_rounded
                        : (isListening
                              ? Icons.stop_rounded
                              : Icons.mic_rounded),
                    color: hasText || isListening
                        ? ChatPalette.accent
                        : ChatPalette.headerSubtitle,
                    size: 30.sp,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
