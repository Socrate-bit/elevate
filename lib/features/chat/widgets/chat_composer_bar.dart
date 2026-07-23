import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';

/// Minimalist composer over the scene: a frosted "+" circle, a frosted pill with
/// the text field, and a trailing action. The trailing icon is a mic while the
/// field is empty (tap → [onMic]) and a send arrow once there is text
/// (tap → [onSend]). Controlled by the parent, which owns [controller].
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
        return Row(
          children: [
            // Leading "+" — its own frosted translucent circle (no-op for now).
            _FrostedCircle(icon: Icons.add_rounded, onTap: () {}),
            SizedBox(width: 10.w),
            // Translucent pill holding the text field + trailing action.
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: EdgeInsets.only(left: 18.w, right: 8.w),
                    decoration: BoxDecoration(
                      color: ChatPalette.composer,
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            onSubmitted: (_) {
                              if (controller.text.trim().isNotEmpty) onSend();
                            },
                            textInputAction: TextInputAction.send,
                            style: TextStyle(
                              color: ChatPalette.composerText,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 18.h,
                              ),
                              border: InputBorder.none,
                              hintText: hint,
                              hintStyle: TextStyle(
                                color: ChatPalette.composerHint,
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
                                  : ChatPalette.composerText,
                              size: 22.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Translucent frosted circular action button.
class _FrostedCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _FrostedCircle({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withHaptic(onTap),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 48.w,
            height: 48.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: ChatPalette.composer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: ChatPalette.composerText, size: 24.sp),
          ),
        ),
      ),
    );
  }
}
