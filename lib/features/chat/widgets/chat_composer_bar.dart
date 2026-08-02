import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';

/// Minimalist composer: a white pill (matching the page background) holding the
/// text field and a trailing send arrow (dimmed until there is text). When the
/// AI attaches rapid replies, a sparkle button appears that toggles the inline
/// proposals panel via [onToggleProposed] (kept out of a modal route so the
/// keyboard stays up). The field grows from one to three lines. Controlled by
/// the parent, which owns [controller].
class ChatComposerBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hint;
  final VoidCallback onSend;

  /// AI-suggested rapid replies; the sparkle button is hidden when empty.
  final List<String> proposedAnswers;

  /// Toggles the inline proposals panel rendered by the parent.
  final VoidCallback onToggleProposed;

  const ChatComposerBar({
    super.key,
    required this.controller,
    this.focusNode,
    required this.hint,
    required this.onSend,
    this.proposedAnswers = const [],
    required this.onToggleProposed,
  });

  @override
  Widget build(BuildContext context) {
    // Rebuild the trailing area as the text changes (empty ⇄ has text).
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final hasText = controller.text.trim().isNotEmpty;
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
                  focusNode: focusNode,
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
              // Sparkle button unfolding the AI's rapid replies (only when the
              // field is empty and suggestions exist).
              if (!hasText && proposedAnswers.isNotEmpty)
                GestureDetector(
                  onTap: withHaptic(onToggleProposed),
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: ChatPalette.accent,
                      size: 26.sp,
                    ),
                  ),
                ),
              SizedBox(width: 6.w),
              GestureDetector(
                onTap: hasText ? withHaptic(onSend) : null,
                child: Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    color: hasText
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
