import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';

/// Bottom input bar with text field, mic toggle, and send button.
class ChatComposer extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isSending;
  final bool isListening;
  final VoidCallback onSend;
  final VoidCallback onMicTap;

  const ChatComposer({
    super.key,
    required this.controller,
    required this.hint,
    required this.isSending,
    required this.isListening,
    required this.onSend,
    required this.onMicTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: c.separator),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              style: TextStyle(fontSize: 15.sp, color: c.textPrimary),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(fontSize: 15.sp, color: c.textSecondary),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          _IconButton(
            icon: isListening ? Icons.stop_rounded : Icons.mic_rounded,
            color: isListening ? c.primary : c.textSecondary,
            background: isListening
                ? c.primary.withAlpha(30)
                : Colors.transparent,
            onTap: onMicTap,
          ),
          SizedBox(width: 6.w),
          _SendButton(
            enabled: !isSending && controller.text.trim().isNotEmpty,
            onTap: onSend,
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  const _IconButton({
    required this.icon,
    required this.color,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withHaptic(onTap),
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, size: 22.sp, color: color),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _SendButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final bg = enabled ? c.primary : c.separator;
    return GestureDetector(
      onTap: enabled ? withHaptic(onTap) : null,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(
          Icons.arrow_upward_rounded,
          size: 20.sp,
          color: Colors.white,
        ),
      ),
    );
  }
}
